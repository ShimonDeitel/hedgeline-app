import Foundation

struct Trim: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var hedgeName: String
    var shapeStyle: String
    var trimNote: String
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), hedgeName: String = "", shapeStyle: String = "", trimNote: String = "", notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.hedgeName = hedgeName
        self.shapeStyle = shapeStyle
        self.trimNote = trimNote
        self.notes = notes
    }
}
