import SwiftUI

// MARK: - App Router
// Ana tab navigation yapısı.
// 5 sekme: Garaj, İşler, Kayıtlar, Belgeler, Raporlar

enum AppTab: String, CaseIterable {
    case garage
    case reminders
    case records
    case documents
    case reports

    var title: LocalizedStringKey {
        switch self {
        case .garage: return "Garaj"
        case .reminders: return "İşler"
        case .records: return "Kayıtlar"
        case .documents: return "Belgeler"
        case .reports: return "Raporlar"
        }
    }

    var icon: String {
        switch self {
        case .garage: return "car"
        case .reminders: return "bell"
        case .records: return "list.bullet"
        case .documents: return "folder"
        case .reports: return "chart.bar"
        }
    }
}

struct AppRouter: View {
    @State private var selectedTab: AppTab = .garage

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(AppColors.accentPrimary)
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .garage:
            GarageView()
        case .reminders:
            RemindersView()
        case .records:
            RecordsView()
        case .documents:
            DocumentsView()
        case .reports:
            ReportsView()
        }
    }
}

#Preview("AppRouter") {
    AppRouter()
}
