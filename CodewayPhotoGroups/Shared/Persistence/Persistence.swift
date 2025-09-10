import Foundation

enum Persistence {
    private static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private static var groupIndexURL: URL { documentsURL.appendingPathComponent("group_index.json") }
    private static var scanStateURL: URL { documentsURL.appendingPathComponent("scan_state.json") }

    static func loadGroupIndex() -> GroupIndex? {
        guard let data = try? Data(contentsOf: groupIndexURL) else { return nil }
        return try? JSONDecoder().decode(GroupIndex.self, from: data)
    }

    static func saveGroupIndex(_ index: GroupIndex) {
        if let data = try? JSONEncoder().encode(index) {
            try? data.write(to: groupIndexURL, options: [.atomic])
        }
    }

    static func loadScanState() -> ScanState? {
        guard let data = try? Data(contentsOf: scanStateURL) else { return nil }
        return try? JSONDecoder().decode(ScanState.self, from: data)
    }

    static func saveScanState(_ state: ScanState) {
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: scanStateURL, options: [.atomic])
        }
    }
}