import CoreGraphics

// MARK: - Radius Token System
// Her şey aynı radius olmayacak. Kullanım amacına göre token seçilir.

enum AppRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 18
    static let xlarge: CGFloat = 24
    static let capsule: CGFloat = 999

    // MARK: Semantic aliases
    static let chip: CGFloat = capsule
    static let row: CGFloat = medium        // Liste satırı: 12
    static let card: CGFloat = large        // Ana kart: 18
    static let heroCard: CGFloat = xlarge   // Hero kart: 24
    static let button: CGFloat = medium     // Buton: 12
    static let sheet: CGFloat = large       // Sheet/modal: native, burada 18 fallback
}

extension CGFloat {
    static let radiusSmall = AppRadius.small
    static let radiusMedium = AppRadius.medium
    static let radiusLarge = AppRadius.large
    static let radiusXLarge = AppRadius.xlarge
    static let radiusCapsule = AppRadius.capsule
}
