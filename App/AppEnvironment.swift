import Foundation

// MARK: - App Environment
// Uygulama genelinde kullanılan çevre değişkenleri ve
// konfigürasyonların merkezi yönetimi.

enum AppEnvironment {
    static let appName = "Ruhsatım"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: Feature flags
    static let isCloudKitSyncEnabled = false
    static let isPartnerVerificationEnabled = false
    static let isSupabaseEnabled = false

    // MARK: Limits
    enum Free {
        static let maxVehicles = 1
        static let maxDocuments = 5
        static let maxSaleFileExports = 2
    }

    enum Pro {
        static let maxVehicles = Int.max
        static let maxDocuments = Int.max
        static let maxSaleFileExports = Int.max
    }
}
