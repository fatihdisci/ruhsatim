import Foundation

// MARK: - Arvia Rehber Insight Models
// AI-ready surface: v1 uses only rule-based local insights.

struct VehicleInsight: Identifiable, Equatable {
    let id: String
    let type: VehicleInsightType
    let priority: VehicleInsightPriority
    let source: VehicleInsightSource
    let title: String
    let body: String
    let action: VehicleInsightAction
    let relatedReminderId: UUID?

    init(
        type: VehicleInsightType,
        priority: VehicleInsightPriority,
        source: VehicleInsightSource = .ruleBased,
        title: String,
        body: String,
        action: VehicleInsightAction,
        relatedReminderId: UUID? = nil
    ) {
        self.id = relatedReminderId.map { "\(type.rawValue)-\($0.uuidString)" } ?? type.rawValue
        self.type = type
        self.priority = priority
        self.source = source
        self.title = title
        self.body = body
        self.action = action
        self.relatedReminderId = relatedReminderId
    }
}

enum VehicleInsightType: String, CaseIterable {
    case maintenance
    case missingDocument
    case saleFileReadiness
    case odometerUpdate
    case overdueReminder
}

enum VehicleInsightPriority: String {
    case info
    case warning
    case important
}

enum VehicleInsightSource: String {
    case ruleBased
    case aiGenerated
}

enum VehicleInsightAction: String, CaseIterable {
    case addServiceRecord
    case addDocument
    case openSaleFile
    case updateOdometer
    case openTodos
    case addInspectionReport

    var title: String {
        switch self {
        case .addServiceRecord:
            return "Bakım Kaydı Ekle"
        case .addDocument:
            return "Belge Ekle"
        case .openSaleFile:
            return "Satış Dosyasına Git"
        case .updateOdometer:
            return "Km Güncelle"
        case .openTodos:
            return "Yapılacaklara Git"
        case .addInspectionReport:
            return "Ekspertiz Ekle"
        }
    }

    var destinationKey: String {
        switch self {
        case .addServiceRecord:
            return "serviceRecordForm"
        case .addDocument:
            return "documentForm"
        case .openSaleFile:
            return "saleFile"
        case .updateOdometer:
            return "vehicleEdit"
        case .openTodos:
            return "todosTab"
        case .addInspectionReport:
            return "inspectionReportForm"
        }
    }
}

