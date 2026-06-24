import Foundation
import SwiftData

// MARK: - Vehicle Document Model
@Model
final class VehicleDocument {
    // CloudKit uyumu için tüm non-optional alanlara property seviyesinde default verildi.
    var id: UUID = UUID()
    var vehicleId: UUID = UUID()
    var typeRaw: String = DocumentType.other.rawValue
    var title: String = ""
    var localFileName: String = ""
    var originalFileName: String?
    var issueDate: Date?
    var expiryDate: Date?
    var vendorName: String?
    var linkedRecordId: UUID?
    var includeInSaleFile: Bool = false
    var fileSizeBytes: Int?
    var createdAt: Date = Date()

    // MARK: - CloudKit Asset
    // Belgenin ikili içeriği. `.externalStorage` ile SwiftData bunu satır içinde değil
    // ayrı bir dosyada saklar; CloudKit açıldığında bu alan CKAsset olarak senkronlanır.
    // Böylece cihaz değişiminde belge dosyaları da yeni cihazda otomatik gelir.
    // Yerel `Documents/VehicleDocuments/` çalışma kopyası korunur (önizleme/performans);
    // bu alan onun senkronlanan yansımasıdır.
    @Attribute(.externalStorage) var fileData: Data?

    // MARK: Computed — Enum
    var type: DocumentType {
        get { DocumentType(rawValue: typeRaw) ?? .other }
        set { typeRaw = newValue.rawValue }
    }

    // MARK: Computed helpers
    var isExpired: Bool {
        guard let expiryDate else { return false }
        return expiryDate < Date()
    }

    var isExpiringSoon: Bool {
        guard let expiryDate, !isExpired else { return false }
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 999
        return daysUntil <= 30
    }

    var daysUntilExpiry: Int? {
        guard let expiryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day
    }

    var fileSizeDisplay: String? {
        guard let bytes = fileSizeBytes else { return nil }
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(bytes / 1024) KB" }
        return String(format: "%.1f MB", Double(bytes) / 1_048_576.0)
    }

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        type: DocumentType = .other,
        title: String = "",
        localFileName: String = "",
        originalFileName: String? = nil,
        issueDate: Date? = nil,
        expiryDate: Date? = nil,
        vendorName: String? = nil,
        linkedRecordId: UUID? = nil,
        includeInSaleFile: Bool = false,
        fileSizeBytes: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.typeRaw = type.rawValue
        self.title = title
        self.localFileName = localFileName
        self.originalFileName = originalFileName
        self.issueDate = issueDate
        self.expiryDate = expiryDate
        self.vendorName = vendorName
        self.linkedRecordId = linkedRecordId
        self.includeInSaleFile = includeInSaleFile
        self.fileSizeBytes = fileSizeBytes
        self.createdAt = createdAt
    }
}
