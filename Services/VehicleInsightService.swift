import Foundation

// MARK: - Vehicle Insight Service
// Generates local, rule-based Arvia Rehber cards. No network or AI calls.

struct VehicleInsightService {
    static let shared = VehicleInsightService()
    static let defaultVisibleLimit = 3

    let calendar: Calendar
    private let fixedNow: Date?

    init(calendar: Calendar = .current, now: Date? = nil) {
        self.calendar = calendar
        self.fixedNow = now
    }

    func insights(
        for vehicle: Vehicle,
        reminders: [Reminder],
        expenses: [Expense],
        serviceRecords: [ServiceRecord],
        documents: [VehicleDocument],
        inspectionReports: [InspectionReport],
        saleFiles: [SaleFile] = [],
        maxVisible: Int = Self.defaultVisibleLimit
    ) -> [VehicleInsight] {
        guard maxVisible > 0 else { return [] }

        var generated: [VehicleInsight] = []

        if let overdue = mostImportantOverdueReminder(reminders, vehicleOdometer: vehicle.currentOdometer) {
            generated.append(overdueReminderInsight(overdue))
        }

        if vehicle.currentOdometer <= 0 {
            generated.append(missingOdometerInsight())
        } else if shouldSuggestOdometerUpdate(
            expenses: expenses,
            serviceRecords: serviceRecords,
            inspectionReports: inspectionReports
        ) {
            generated.append(staleOdometerInsight())
        }

        if serviceRecords.isEmpty {
            generated.append(noServiceRecordInsight())
        } else if let latestService = serviceRecords.max(by: { $0.date < $1.date }),
                  isOlderThanMonths(latestService.date, months: 12) {
            generated.append(oldServiceRecordInsight())
        }

        if documents.isEmpty {
            generated.append(noDocumentInsight())
        }

        if inspectionReports.isEmpty {
            generated.append(noInspectionSaleReadinessInsight())
        } else if isSaleFileWeak(serviceRecords: serviceRecords, documents: documents, inspectionReports: inspectionReports) {
            generated.append(weakSaleFileInsight())
        }

        return Array(generated.prefix(maxVisible))
    }

    private func mostImportantOverdueReminder(_ reminders: [Reminder], vehicleOdometer: Int) -> Reminder? {
        reminders
            .filter { reminder in
                reminder.statusRaw != ReminderStatus.completed.rawValue &&
                reminder.statusRaw != ReminderStatus.archived.rawValue &&
                (reminder.isOverdue || reminder.isKmOverdue(vehicleOdometer: vehicleOdometer))
            }
            .sorted { lhs, rhs in
                if lhs.priority != rhs.priority {
                    return priorityRank(lhs.priority) > priorityRank(rhs.priority)
                }
                return (lhs.dueDate ?? .distantPast) < (rhs.dueDate ?? .distantPast)
            }
            .first
    }

    private func priorityRank(_ priority: ReminderPriority) -> Int {
        switch priority {
        case .critical:
            return 3
        case .warning:
            return 2
        case .info:
            return 1
        }
    }

    private func shouldSuggestOdometerUpdate(
        expenses: [Expense],
        serviceRecords: [ServiceRecord],
        inspectionReports: [InspectionReport]
    ) -> Bool {
        let datedOdometerEvidence = [
            expenses.compactMap { expense in expense.odometer == nil ? nil : expense.date },
            serviceRecords.compactMap { service in service.odometer == nil ? nil : service.date },
            inspectionReports.compactMap { report in report.odometer == nil ? nil : report.reportDate },
        ].flatMap { $0 }

        guard let latest = datedOdometerEvidence.max() else { return false }
        return isOlderThanMonths(latest, months: 6)
    }

    private func isOlderThanMonths(_ date: Date, months: Int) -> Bool {
        guard let threshold = calendar.date(byAdding: .month, value: -months, to: fixedNow ?? Date()) else { return false }
        return date < threshold
    }

    private func isSaleFileWeak(
        serviceRecords: [ServiceRecord],
        documents: [VehicleDocument],
        inspectionReports: [InspectionReport]
    ) -> Bool {
        let missingSignals = [
            serviceRecords.isEmpty,
            documents.isEmpty,
            inspectionReports.isEmpty,
        ].filter { $0 }.count

        return missingSignals >= 2
    }

    private func overdueReminderInsight(_ reminder: Reminder) -> VehicleInsight {
        VehicleInsight(
            type: .overdueReminder,
            priority: .important,
            title: "Geciken işi tamamla",
            body: "Geciken hatırlatıcıları kapatmak dosyanın güncel kalmasına yardımcı olur.",
            action: .openTodos,
            relatedReminderId: reminder.id
        )
    }

    private func missingOdometerInsight() -> VehicleInsight {
        VehicleInsight(
            type: .odometerUpdate,
            priority: .warning,
            title: "Kilometre bilgisini güncelle",
            body: "Güncel kilometre, bakım ve masraf takibini daha anlamlı hale getirir.",
            action: .updateOdometer
        )
    }

    private func staleOdometerInsight() -> VehicleInsight {
        VehicleInsight(
            type: .odometerUpdate,
            priority: .info,
            title: "Kilometre bilgisini güncelle",
            body: "Kayıtlarında son kilometre bilgisi eski görünüyor. Güncel km eklemek bakım ve masraf takibini daha anlamlı hale getirir.",
            action: .updateOdometer
        )
    }

    private func noServiceRecordInsight() -> VehicleInsight {
        VehicleInsight(
            type: .maintenance,
            priority: .info,
            title: "Son bakımını kontrol et",
            body: "Kayıtlarına göre son bakım geçmişi eksik veya eski görünüyor. Yağ, filtre ve genel bakım kayıtlarını eklemek faydalı olabilir.",
            action: .addServiceRecord
        )
    }

    private func oldServiceRecordInsight() -> VehicleInsight {
        VehicleInsight(
            type: .maintenance,
            priority: .warning,
            title: "Son bakımını kontrol et",
            body: "Kayıtlarında son bakımın üzerinden uzun süre geçmiş görünüyor. Bakım geçmişini gözden geçirmek faydalı olabilir.",
            action: .addServiceRecord
        )
    }

    private func noDocumentInsight() -> VehicleInsight {
        VehicleInsight(
            type: .missingDocument,
            priority: .info,
            title: "Dosyana belge ekle",
            body: "Poliçe, muayene, ekspertiz veya servis faturalarını ekleyerek aracının geçmişini daha düzenli tutabilirsin.",
            action: .addDocument
        )
    }

    private func noInspectionSaleReadinessInsight() -> VehicleInsight {
        VehicleInsight(
            type: .saleFileReadiness,
            priority: .info,
            title: "Satış dosyanı güçlendir",
            body: "Bakım kayıtları, belgeler ve ekspertiz raporu satış dosyanın daha güven veren görünmesine yardımcı olur.",
            action: .addInspectionReport
        )
    }

    private func weakSaleFileInsight() -> VehicleInsight {
        VehicleInsight(
            type: .saleFileReadiness,
            priority: .info,
            title: "Satış dosyanı güçlendir",
            body: "Bakım kayıtları, belgeler ve ekspertiz raporu satış dosyanın daha güven veren görünmesine yardımcı olur.",
            action: .openSaleFile
        )
    }
}
