import Foundation
import SwiftData

// MARK: - Reminder Model
@Model
final class Reminder {
    // CloudKit uyumu için tüm non-optional alanlara property seviyesinde default verildi.
    var id: UUID = UUID()
    var vehicleId: UUID = UUID()
    var typeRaw: String = ReminderType.custom.rawValue
    var title: String = ""
    var dueDate: Date?
    var dueOdometer: Int?
    var repeatRuleRaw: String?
    var priorityRaw: String = ReminderPriority.info.rawValue
    var statusRaw: String = ReminderStatus.active.rawValue
    var completedAt: Date?
    var notes: String = ""
    var createdAt: Date = Date()

    // MARK: Computed — Enum dönüşümleri
    var type: ReminderType {
        get { ReminderType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    var priority: ReminderPriority {
        get { ReminderPriority(rawValue: priorityRaw) ?? .info }
        set { priorityRaw = newValue.rawValue }
    }

    var status: ReminderStatus {
        get { ReminderStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    // MARK: Computed properties
    var isOverdue: Bool {
        guard statusRaw != ReminderStatus.completed.rawValue,
              statusRaw != ReminderStatus.archived.rawValue,
              let dueDate else { return false }
        return dueDate < Date()
    }

    var isToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var isUpcoming: Bool {
        guard let dueDate, !isOverdue, !isToday else { return false }
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 999
        return daysUntil <= 30
    }

    /// Gecikme gün sayısı. Gelecekse 0, gecikmişse pozitif.
    var daysOverdue: Int {
        guard let dueDate, isOverdue else { return 0 }
        return Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day ?? 0
    }

    /// Kalan gün. Gecikmişse negatif.
    var daysRemaining: Int {
        guard let dueDate else { return 999 }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 999
    }

    // MARK: Group helper
    enum GroupKey: String {
        case overdue = "Gecikenler"
        case today = "Bugün"
        case upcoming = "Yaklaşanlar"
        case later = "Daha Sonra"
    }

    var groupKey: GroupKey {
        if statusRaw == ReminderStatus.completed.rawValue { return .later }
        if isOverdue { return .overdue }
        if isToday { return .today }
        if isUpcoming { return .upcoming }
        return .later
    }

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        type: ReminderType = .custom,
        title: String = "",
        dueDate: Date? = nil,
        dueOdometer: Int? = nil,
        repeatRule: String? = nil,
        priority: ReminderPriority = .info,
        status: ReminderStatus = .active,
        completedAt: Date? = nil,
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.typeRaw = type.rawValue
        self.title = title
        self.dueDate = dueDate
        self.dueOdometer = dueOdometer
        self.repeatRuleRaw = repeatRule
        self.priorityRaw = priority.rawValue
        self.statusRaw = status.rawValue
        self.completedAt = completedAt
        self.notes = notes
        self.createdAt = createdAt
    }
}
