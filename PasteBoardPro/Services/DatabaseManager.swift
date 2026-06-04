import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()

    private var items: [ClipboardItem] = []
    private let fileURL: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupport.appendingPathComponent("PasteBoardPro", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("clipboard.json")
        load()
    }

    func setup() throws {
        load()
    }

    func fetchAll() -> [ClipboardItem] {
        return items.sorted { a, b in
            if a.isPinned != b.isPinned { return a.isPinned }
            return a.createdAt > b.createdAt
        }
    }

    func insert(_ item: ClipboardItem) {
        items.append(item)
        save()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    func togglePin(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isPinned.toggle()
            save()
        }
    }

    func deleteExpired() {
        let now = Date()
        items.removeAll { !$0.isPinned && $0.expiresAt < now }
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL)
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        items = (try? JSONDecoder().decode([ClipboardItem].self, from: data)) ?? []
    }
}
