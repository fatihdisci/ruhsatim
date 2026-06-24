import SwiftUI
import SwiftData

// MARK: - App Entry Point
// @main uygulama girişi.
// SwiftData container yapılandırması ve root view.

@main
struct VehicleDossierApp: App {
    let modelContainer: ModelContainer
    @StateObject private var paywallService = PaywallService.shared

    init() {
        do {
            let schema = Schema([
                Vehicle.self,
                Reminder.self,
                Expense.self,
                ServiceRecord.self,
                PartChange.self,
                VehicleDocument.self,
                InspectionReport.self,
                SaleFile.self,
            ])
            let modelConfiguration = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
        } catch {
            fatalError("SwiftData ModelContainer başlatılamadı: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .modelContainer(modelContainer)
                .environmentObject(paywallService)
                .environment(\.locale, Locale(identifier: "tr_TR"))
        }
    }
}
