import Foundation
import SwiftData

// MARK: - Inspection Report Model
@Model
final class InspectionReport {
    // CloudKit uyumu için tüm non-optional alanlara property seviyesinde default verildi.
    var id: UUID = UUID()
    var vehicleId: UUID = UUID()
    var providerName: String = ""
    var branchName: String?
    var reportDate: Date = Date()
    var odometer: Int?
    var summary: String = ""
    var documentId: UUID?
    var verificationStatusRaw: String = VerificationStatus.manual.rawValue
    var includeInSaleFile: Bool = false
    var createdAt: Date = Date()

    // MARK: Computed — Enum
    var verificationStatus: VerificationStatus {
        get { VerificationStatus(rawValue: verificationStatusRaw) ?? .manual }
        set { verificationStatusRaw = newValue.rawValue }
    }

    // MARK: Formatting helpers
    var dateDisplay: String {
        reportDate.formatted(date: .abbreviated, time: .omitted)
    }

    var odometerDisplay: String? {
        odometer.map { "\($0.formatted()) km" }
    }

    // MARK: Uyarı metni
    static let legalDisclaimer = "Bu ekspertiz raporu kullanıcı tarafından eklenmiştir. Uygulama, rapor içeriğinin doğruluğunu veya güncelliğini garanti etmez."

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        providerName: String = "",
        branchName: String? = nil,
        reportDate: Date = Date(),
        odometer: Int? = nil,
        summary: String = "",
        documentId: UUID? = nil,
        verificationStatus: VerificationStatus = .manual,
        includeInSaleFile: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.providerName = providerName
        self.branchName = branchName
        self.reportDate = reportDate
        self.odometer = odometer
        self.summary = summary
        self.documentId = documentId
        self.verificationStatusRaw = verificationStatus.rawValue
        self.includeInSaleFile = includeInSaleFile
        self.createdAt = createdAt
    }
}
