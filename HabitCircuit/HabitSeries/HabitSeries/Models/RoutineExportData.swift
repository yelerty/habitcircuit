import Foundation

// MARK: - Export/Import Data Structures
struct RoutineExportData: Codable {
    let version: String
    let exportDate: Date
    let routines: [ExportableRoutine]

    struct ExportableRoutine: Codable {
        let name: String
        let dayOfWeek: String
        let timeType: String
        let order: Int
    }
}

// MARK: - Export/Import Manager
class RoutineExportManager {
    static let shared = RoutineExportManager()
    private init() {}

    // MARK: - Export Routines to JSON
    func exportRoutines(routines: [RoutineItem]) -> Data? {
        let exportableRoutines = routines.map { routine in
            RoutineExportData.ExportableRoutine(
                name: routine.name,
                dayOfWeek: routine.dayOfWeek,
                timeType: routine.timeType.rawValue,
                order: routine.order
            )
        }

        let exportData = RoutineExportData(
            version: "1.0",
            exportDate: Date(),
            routines: exportableRoutines
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let jsonData = try encoder.encode(exportData)
            return jsonData
        } catch {
            print("Error encoding routines: \(error)")
            return nil
        }
    }

    // MARK: - Import Routines from JSON
    func importRoutines(from data: Data) -> [RoutineExportData.ExportableRoutine]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let exportData = try decoder.decode(RoutineExportData.self, from: data)
            return exportData.routines
        } catch {
            print("Error decoding routines: \(error)")
            return nil
        }
    }

    // MARK: - Generate File Name
    func generateFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let dateString = dateFormatter.string(from: Date())
        return "HabitSeries-\(dateString).json"
    }
}
