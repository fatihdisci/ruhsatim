// MARK: - DesignSystem Umbrella
// Tüm tasarım tokenlarını ve komponentlerini dışa aktaran merkezi dosya.
// Feature modülleri yalnızca bu dosyayı import ederek DesignSystem'e erişebilir.

// Design tokens are available through their respective enums:
// - AppColors / Color.appXxx extensions
// - AppSpacing / CGFloat.xxx extensions
// - AppRadius / CGFloat.radiusXxx extensions
// - AppTypography / Font extensions
// - AppShadows / View.xxxShadow() modifiers
// - ButtonStyle.primary / .secondary / .destructive / .text

// Reusable components are available as standalone SwiftUI views:
// - EmptyStateView
// - ErrorStateView
// - SectionHeader
// - MetricCard
