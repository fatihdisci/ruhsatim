import Foundation

// MARK: - App Brand Constants
// Merkezi marka/branding sabitleri. Tüm hardcoded "Garajım" metinleri
// bu dosya üzerinden referanslanır. App adı değişirse tek yerden güncellenir.

enum AppBrand {
    /// Uygulamanın görünen adı
    static let appName = "Garajım"

    /// Geçici alternatif isim (ileride kullanılabilir)
    static let alternativeName = "Arvia"

    /// Tagline / slogan
    static let tagline = "Aracının dijital yaşam dosyası"

    /// Bundle identifier (değişmez)
    static let bundleIdentifier = "com.ruhsatim.app"
}
