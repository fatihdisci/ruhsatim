import Foundation
import SwiftData

// MARK: - Part Change Model
@Model
final class PartChange {
    // CloudKit uyumu için tüm non-optional alanlara property seviyesinde default verildi.
    var id: UUID = UUID()
    var serviceRecordId: UUID = UUID()
    var partTypeRaw: String = PartType.custom.rawValue
    var brand: String?
    var model: String?
    var warrantyUntil: Date?
    var note: String = ""
    var createdAt: Date = Date()

    var partType: PartType {
        get { PartType(rawValue: partTypeRaw) ?? .custom }
        set { partTypeRaw = newValue.rawValue }
    }

    var partDisplay: String {
        [brand, model].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
    }

    init(
        id: UUID = UUID(),
        serviceRecordId: UUID,
        partType: PartType = .custom,
        brand: String? = nil,
        model: String? = nil,
        warrantyUntil: Date? = nil,
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.serviceRecordId = serviceRecordId
        self.partTypeRaw = partType.rawValue
        self.brand = brand
        self.model = model
        self.warrantyUntil = warrantyUntil
        self.note = note
        self.createdAt = createdAt
    }
}
