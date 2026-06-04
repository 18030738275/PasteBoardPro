import Foundation

enum ItemType: String, Codable, CaseIterable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable {
    var id: UUID
    var type: ItemType
    var content: String?
    var imagePath: String?
    var createdAt: Date
    var isPinned: Bool
    var expiresAt: Date

    init(id: UUID = UUID(), type: ItemType, content: String? = nil, imagePath: String? = nil, createdAt: Date = Date(), isPinned: Bool = false, expiresInDays: Int = 3) {
        self.id = id
        self.type = type
        self.content = content
        self.imagePath = imagePath
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.expiresAt = Calendar.current.date(byAdding: .day, value: expiresInDays, to: createdAt) ?? createdAt
    }

    var isExpired: Bool {
        Date() > expiresAt
    }

    var previewText: String {
        if type == .image {
            return imagePath?.components(separatedBy: "/").last ?? "图片"
        }
        let text = content ?? ""
        return text.count > 60 ? String(text.prefix(60)) + "..." : text
    }
}
