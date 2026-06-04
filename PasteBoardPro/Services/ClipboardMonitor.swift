import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    @Published var items: [ClipboardItem] = []

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let dbManager = DatabaseManager.shared
    private let pasteboard = NSPasteboard.general
    private var imageFolder: URL?
    private var isWritingToPasteboard = false

    init() {
        loadSettings()
    }

    func start() {
        lastChangeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        refreshItems()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refreshItems() {
        items = dbManager.fetchAll()
    }

    func deleteItem(id: UUID) {
        dbManager.delete(id: id)
        refreshItems()
    }

    func togglePin(id: UUID) {
        dbManager.togglePin(id: id)
        refreshItems()
    }

    func copyToClipboard(_ item: ClipboardItem) {
        isWritingToPasteboard = true
        pasteboard.clearContents()
        if item.type == .text, let content = item.content {
            pasteboard.setString(content, forType: .string)
        } else if item.type == .image, let path = item.imagePath {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url) {
                let ext = (path as NSString).pathExtension.lowercased()
                let pbType: NSPasteboard.PasteboardType = {
                    switch ext {
                    case "png": return .png
                    case "jpg", "jpeg": return NSPasteboard.PasteboardType("public.jpeg")
                    case "gif": return NSPasteboard.PasteboardType("com.compuserve.gif")
                    default: return .tiff
                    }
                }()
                pasteboard.setData(data, forType: pbType)
            }
        }
        lastChangeCount = pasteboard.changeCount
        isWritingToPasteboard = false
    }

    func updateSettings(expiresInDays: Int, imageFolder: URL?) {
        UserDefaults.standard.set(expiresInDays, forKey: "expiresInDays")
        if let folder = imageFolder {
            UserDefaults.standard.set(folder.path, forKey: "imageFolderPath")
            self.imageFolder = folder
        }
    }

    func loadSettings() {
        let days = UserDefaults.standard.integer(forKey: "expiresInDays")
        if days == 0 {
            UserDefaults.standard.set(3, forKey: "expiresInDays")
        }
        if let path = UserDefaults.standard.string(forKey: "imageFolderPath") {
            imageFolder = URL(fileURLWithPath: path)
        }
    }

    var expiresInDays: Int {
        UserDefaults.standard.integer(forKey: "expiresInDays")
    }

    var imageFolderPath: String {
        UserDefaults.standard.string(forKey: "imageFolderPath") ?? ""
    }

    private func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        guard !isWritingToPasteboard else { return }

        // 优先：检测是否为图片文件（截图等保存为文件的情况）
        if let filenames = pasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String],
           let path = filenames.first {
            let ext = (path as NSString).pathExtension.lowercased()
            let imageExts = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "tif", "webp", "heic"]
            if imageExts.contains(ext), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                saveImageFromData(data, originalPath: path)
                playCopySound()
                return
            }
        }

        // 其次：检测剪贴板中的图片数据（从网页等复制的图片）
        if let imageData = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png) {
            saveImageFromData(imageData)
            playCopySound()
        } else if let string = pasteboard.string(forType: .string), !string.isEmpty {
            saveTextItem(string)
            playCopySound()
        }
    }

    private func playCopySound() {
        NSSound(named: .init("Pop"))?.play()
    }

    private func saveTextItem(_ text: String) {
        let days = expiresInDays > 0 ? expiresInDays : 3
        let item = ClipboardItem(type: .text, content: text, expiresInDays: days)
        dbManager.insert(item)
        dbManager.deleteExpired()
        refreshItems()
    }

    private func saveImageFromData(_ data: Data, originalPath: String? = nil) {
        guard let folder = ensureImageFolder() else { return }
        let ext = originalPath.map { ($0 as NSString).pathExtension } ?? "tiff"
        let filename = "clipboard_\(Int(Date().timeIntervalSince1970)).\(ext)"
        let fileURL = folder.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            let days = expiresInDays > 0 ? expiresInDays : 3
            let item = ClipboardItem(type: .image, imagePath: fileURL.path, expiresInDays: days)
            dbManager.insert(item)
            dbManager.deleteExpired()
            refreshItems()
        } catch {
            print("Save image error: \(error)")
        }
    }

    private func ensureImageFolder() -> URL? {
        if let folder = imageFolder { return folder }
        let fallback = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("PasteBoardPro/Images", isDirectory: true)
        try? FileManager.default.createDirectory(at: fallback, withIntermediateDirectories: true)
        imageFolder = fallback
        return fallback
    }
}
