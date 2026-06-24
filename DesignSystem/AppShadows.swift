import SwiftUI

// MARK: - Shadow System
// Gölge az ve anlamlı kullanılır.
// Surface ayrımı çoğunlukla renk/border ile yapılır.
// Hero/satış dosyası gibi premium anlarda yumuşak gölge olabilir.
// Dark mode'da gölge yerine border/surface contrast kullanılır.

enum AppShadows {
    // MARK: Shadow parameters
    static let subtleColor = Color.black.opacity(0.04)
    static let subtleRadius: CGFloat = 4
    static let subtleX: CGFloat = 0
    static let subtleY: CGFloat = 2

    static let cardColor = Color.black.opacity(0.06)
    static let cardRadius: CGFloat = 8
    static let cardX: CGFloat = 0
    static let cardY: CGFloat = 4

    static let elevatedColor = Color.black.opacity(0.08)
    static let elevatedRadius: CGFloat = 16
    static let elevatedX: CGFloat = 0
    static let elevatedY: CGFloat = 6

    // MARK: - ViewModifiers
    struct SubtleShadow: ViewModifier {
        @Environment(\.colorScheme) var colorScheme

        func body(content: Content) -> some View {
            if colorScheme == .dark {
                content
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.medium)
                            .stroke(Color.appBorder, lineWidth: 0.5)
                    )
            } else {
                content
                    .shadow(
                        color: AppShadows.subtleColor,
                        radius: AppShadows.subtleRadius,
                        x: AppShadows.subtleX,
                        y: AppShadows.subtleY
                    )
            }
        }
    }

    struct CardShadow: ViewModifier {
        @Environment(\.colorScheme) var colorScheme

        func body(content: Content) -> some View {
            if colorScheme == .dark {
                content
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .stroke(Color.appBorder, lineWidth: 0.5)
                    )
            } else {
                content
                    .shadow(
                        color: AppShadows.cardColor,
                        radius: AppShadows.cardRadius,
                        x: AppShadows.cardX,
                        y: AppShadows.cardY
                    )
            }
        }
    }

    struct ElevatedShadow: ViewModifier {
        @Environment(\.colorScheme) var colorScheme

        func body(content: Content) -> some View {
            if colorScheme == .dark {
                content
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.heroCard)
                            .stroke(Color.appBorder, lineWidth: 0.5)
                    )
            } else {
                content
                    .shadow(
                        color: AppShadows.elevatedColor,
                        radius: AppShadows.elevatedRadius,
                        x: AppShadows.elevatedX,
                        y: AppShadows.elevatedY
                    )
            }
        }
    }
}

extension View {
    func subtleShadow() -> some View {
        modifier(AppShadows.SubtleShadow())
    }

    func cardShadow() -> some View {
        modifier(AppShadows.CardShadow())
    }

    func elevatedShadow() -> some View {
        modifier(AppShadows.ElevatedShadow())
    }
}
