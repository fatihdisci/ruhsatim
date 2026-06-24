import Foundation
import SwiftData

// MARK: - Service Record Model
@Model
final class ServiceRecord {
    // CloudKit uyumu için tüm non-optional alanlara property seviyesinde default verildi.
    var id: UUID = UUID()
    var vehicleId: UUID = UUID()
    var serviceTypeRaw: String = ServiceType.custom.rawValue
    var date: Date = Date()
    var odometer: Int?
    var vendorName: String?
    var laborCost: Double?
    var partsCost: Double?
    var totalCost: Double?
    var oilType: String?
    var notes: String = ""
    var documentIds: [UUID] = []
    var nextReminderTypeRaw: String?
    var nextReminderDueDate: Date?
    var nextReminderDueOdometer: Int?
    var createdAt: Date = Date()

    // MARK: Computed — Enum
    var serviceType: ServiceType {
        get { ServiceType(rawValue: serviceTypeRaw) ?? .custom }
        set { serviceTypeRaw = newValue.rawValue }
    }

    var nextReminderType: ReminderType? {
        get {
            guard let raw = nextReminderTypeRaw else { return nil }
            return ReminderType(rawValue: raw)
        }
        set { nextReminderTypeRaw = newValue?.rawValue }
    }

    // MARK: Formatting helpers
    var totalCostDisplay: String? {
        let cost = totalCost ?? (laborCost ?? 0) + (partsCost ?? 0)
        guard cost > 0 else { return nil }
        return "₺\(String(format: "%.0f", cost))"
    }

    var dateDisplay: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    var odometerDisplay: String? {
        odometer.map { "\($0.formatted()) km" }
    }

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        serviceType: ServiceType = .custom,
        date: Date = Date(),
        odometer: Int? = nil,
        vendorName: String? = nil,
        laborCost: Double? = nil,
        partsCost: Double? = nil,
        totalCost: Double? = nil,
        oilType: String? = nil,
        notes: String = "",
        documentIds: [UUID] = [],
        nextReminderType: ReminderType? = nil,
        nextReminderDueDate: Date? = nil,
        nextReminderDueOdometer: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.serviceTypeRaw = serviceType.rawValue
        self.date = date
        self.odometer = odometer
        self.vendorName = vendorName
        self.laborCost = laborCost
        self.partsCost = partsCost
        self.totalCost = totalCost
        self.oilType = oilType
        self.notes = notes
        self.documentIds = documentIds
        self.nextReminderTypeRaw = nextReminderType?.rawValue
        self.nextReminderDueDate = nextReminderDueDate
        self.nextReminderDueOdometer = nextReminderDueOdometer
        self.createdAt = createdAt
    }
}
