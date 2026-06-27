import Foundation

// MARK: - Supabase Configuration
// Supabase bağlantı ayarlarını xcconfig üzerinden okur.
// xcconfig eksik veya placeholder ise isConfigured = false döner;
// topluluk özelliği crash yerine "hazırlanıyor" boş durumu gösterir.
//
// Okuma stratejisi:
// 1. Önce INFOPLIST_KEY_SUPABASE_URL / INFOPLIST_KEY_SUPABASE_ANON_KEY dener
//    (GENERATE_INFOPLIST_FILE = YES ile otomatik Info.plist'e eklenen key'ler)
// 2. Bulunamazsa SUPABASE_URL / SUPABASE_ANON_KEY fallback dener
//    (manuel Info.plist veya User-Defined build settings)

enum SupabaseConfig {
    /// Supabase proje URL'si.
    static var supabaseURL: URL? {
        guard let urlString = Self.value(forKeys: [
            "SUPABASE_URL",
        ]),
              !urlString.isEmpty,
              !urlString.contains("YOUR-PROJECT"),
              let url = URL(string: urlString) else {
            logMissing("SUPABASE_URL")
            return nil
        }
        return url
    }

    /// Supabase anon key.
    static var supabaseAnonKey: String? {
        guard let key = Self.value(forKeys: [
            "SUPABASE_ANON_KEY",
        ]),
              !key.isEmpty,
              !key.contains("YOUR_ANON_KEY") else {
            logMissing("SUPABASE_ANON_KEY")
            return nil
        }
        return key
    }

    /// Config eksiksiz doldurulmuşsa true.
    static var isConfigured: Bool {
        let configured = supabaseURL != nil && supabaseAnonKey != nil
        if !configured {
            logState()
        }
        return configured
    }

    /// Debug build'lerde config durumunu gösterir.
    static func debugState() -> String {
        var lines: [String] = []
        lines.append("Supabase configured: \(isConfigured)")
        lines.append("URL present: \(supabaseURL != nil)")
        lines.append("Anon key present: \(supabaseAnonKey != nil)")

        for key in ["SUPABASE_URL", "SUPABASE_ANON_KEY"] {
            if let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String {
                lines.append("\(key): \(raw.prefix(30))...")
            } else {
                lines.append("\(key): nil")
            }
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    /// Verilen key'leri sırayla dener, ilk bulunanı döner.
    private static func value(forKeys keys: [String]) -> String? {
        for key in keys {
            if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
               !value.isEmpty {
                return value
            }
        }
        return nil
    }

    private static func logMissing(_ key: String) {
        #if DEBUG
        let found = Bundle.main.object(forInfoDictionaryKey: key) as? String
        print("[SupabaseConfig] ❌ \(key): \(found == nil ? "nil" : "placeholder/empty (\"\(found!.prefix(20))...\")")")
        #endif
    }

    private static func logState() {
        #if DEBUG
        print("[SupabaseConfig] isConfigured = false")
        for key in ["SUPABASE_URL", "SUPABASE_ANON_KEY"] {
            let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String
            print("[SupabaseConfig]   \(key) = \(raw ?? "nil")")
        }
        #endif
    }
}
