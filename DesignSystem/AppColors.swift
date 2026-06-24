import SwiftUI

// MARK: - Semantic Color System
// Design token tabanlı renk sistemi. Hiçbir feature view'da ham hex kullanılmaz.
// Tüm renkler light/dark mode adaptive olarak tanımlanmıştır.

enum AppColors {
    // MARK: Background
    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let surfacePrimary = Color("SurfacePrimary")
    static let surfaceSecondary = Color("SurfaceSecondary")

    // MARK: Text
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    static let textOnAccent = Color("TextOnAccent")

    // MARK: Accent
    static let accentPrimary = Color("AccentPrimary")
    static let accentSecondary = Color("AccentSecondary")
    static let accentMuted = Color("AccentMuted")

    // MARK: Semantic
    static let success = Color("Success")
    static let successBackground = Color("SuccessBackground")
    static let warning = Color("Warning")
    static let warningBackground = Color("WarningBackground")
    static let critical = Color("Critical")
    static let criticalBackground = Color("CriticalBackground")

    // MARK: Functional
    static let document = Color("Document")
    static let vehicle = Color("Vehicle")
    static let border = Color("Border")
    static let divider = Color("Divider")

    // MARK: TabBar
    static let tabBarBackground = Color("TabBarBackground")
    static let tabBarInactive = Color("TabBarInactive")
}

// MARK: - SwiftUI Color extensions for semantic usage
extension Color {
    // Background
    static let appBackground = AppColors.backgroundPrimary
    static let appSurface = AppColors.surfacePrimary

    // Text
    static let appTextPrimary = AppColors.textPrimary
    static let appTextSecondary = AppColors.textSecondary

    // Accent
    static let appAccent = AppColors.accentPrimary
    static let appAccentSecondary = AppColors.accentSecondary

    // Semantic
    static let appSuccess = AppColors.success
    static let appWarning = AppColors.warning
    static let appCritical = AppColors.critical

    // Functional
    static let appBorder = AppColors.border
}
