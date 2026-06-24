import Foundation
import SwiftData

// MARK: - Sale File Model
@Model
final class SaleFile {
    // CloudKit uyumu için tüm non-optional alanlara property seviyesinde default verildi.
    var id: UUID = UUID()
    var vehicleId: UUID = UUID()
    var title: String = ""
    var includedSectionsRaw: [String] = []
    var selectedDocumentIds: [UUID] = []
    var selectedInspectionReportIds: [UUID] = []
    var includePhotos: Bool = false
    var generatedPDFFileName: String?
    var shareLinkURL: String?
    var shareLinkExpiry: Date?
    var viewCount: Int = 0
    var createdAt: Date = Date()

    // MARK: Computed — Enum dizisi
    var includedSections: [SaleFileSection] {
        get { includedSectionsRaw.compactMap { SaleFileSection(rawValue: $0) } }
        set { includedSectionsRaw = newValue.map { $0.rawValue } }
    }

    // MARK: Hukuki uyarı
    static let legalDisclaimer = "Bu dosya, kullanıcı tarafından uygulamaya eklenen kayıt ve belgelerden oluşturulmuştur. Uygulama, araç hakkında teknik, hukuki veya mekanik garanti vermez. Belgelerin ve bilgilerin doğruluğundan ilgili kullanıcı ve/veya belgeyi düzenleyen kişi/kurum sorumludur."

    static let shortDisclaimer = "Bu dosya kullanıcı kayıtlarından oluşturulmuştur; mekanik veya hukuki garanti anlamına gelmez."

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        title: String = "",
        includedSections: [SaleFileSection] = [.summary, .serviceHistory, .documents, .disclaimer],
        selectedDocumentIds: [UUID] = [],
        selectedInspectionReportIds: [UUID] = [],
        includePhotos: Bool = false,
        generatedPDFFileName: String? = nil,
        shareLinkURL: String? = nil,
        shareLinkExpiry: Date? = nil,
        viewCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.title = title
        self.includedSectionsRaw = includedSections.map { $0.rawValue }
        self.selectedDocumentIds = selectedDocumentIds
        self.selectedInspectionReportIds = selectedInspectionReportIds
        self.includePhotos = includePhotos
        self.generatedPDFFileName = generatedPDFFileName
        self.shareLinkURL = shareLinkURL
        self.shareLinkExpiry = shareLinkExpiry
        self.viewCount = viewCount
        self.createdAt = createdAt
    }
}
