import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Trim] = []
    @Published var isPro: Bool = false

    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("hedgeline_items.json")
        load()
    }

    var canAddMore: Bool { isPro || items.count < Store.freeLimit }

    func add(_ item: Trim) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Trim) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Trim) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Trim].self, from: data) {
            items = decoded
        } else {
            items = [
        Trim(hedgeName: "Front boxwood", shapeStyle: "Ball", trimNote: "Spring shape-up", notes: ""),
        Trim(hedgeName: "Side privet", shapeStyle: "Formal wall", trimNote: "Midsummer trim", notes: "")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
