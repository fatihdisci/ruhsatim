import SwiftUI
import SwiftData

// MARK: - Belgeler (Documents) Tab
// Belge kasası: türe göre gruplandırılmış liste, ekleme, önizleme.

struct DocumentsView: View {
    @EnvironmentObject private var paywallService: PaywallService
    @Query(sort: \VehicleDocument.createdAt, order: .reverse) private var allDocuments: [VehicleDocument]

    @State private var showAddDocument = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            DocumentListView()
                .navigationTitle("Belgeler")
                .background(Color.appBackground)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            if paywallService.canAddDocument(currentCount: allDocuments.count) {
                                showAddDocument = true
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(AppColors.accentPrimary)
                        }
                        .accessibilityLabel("Belge Ekle")
                    }
                }
                .sheet(isPresented: $showAddDocument) {
                    DocumentFormView()
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView(feature: .documentLimit)
                }
        }
    }
}

#Preview("Belgeler — Boş") {
    DocumentsView()
}

#Preview("Belgeler — Dolu") {
    DocumentsView()
        .modelContainer(MockDataProvider.previewContainer)
}
