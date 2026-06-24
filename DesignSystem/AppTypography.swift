import SwiftUI

// MARK: - Typography System
// Native SF Pro hissi, SwiftUI sistem text style'ları kullanılır.
// Dynamic Type otomatik desteklenir.

enum AppTypography {
    // Hero sayılar (38-44pt, light/medium)
    static var heroNumber: Font { .system(size: 40, weight: .light, design: .default) }

    // Ekran başlığı
    static var screenTitle: Font { .largeTitle } // 34pt bold
    static var screenTitleWeight: Font { .system(size: 28, weight: .bold) }

    // Bölüm başlığı
    static var sectionTitle: Font { .title2 } // 22pt semibold
    static var sectionTitleSmall: Font { .system(size: 20, weight: .semibold) }

    // Kart başlığı
    static var cardTitle: Font { .headline } // 17pt semibold
    static var cardTitleSmall: Font { .system(size: 18, weight: .semibold) }

    // Body
    static var body: Font { .body } // 17pt regular
    static var bodyMedium: Font { .system(size: 16, weight: .medium) }

    // İkincil
    static var secondary: Font { .subheadline } // 15pt regular
    static var secondarySmall: Font { .system(size: 14, weight: .regular) }

    // Caption
    static var caption: Font { .caption } // 12pt regular
    static var captionMedium: Font { .system(size: 13, weight: .medium) }

    // Özel: Plaka, tutar, tarih gibi kritik bilgiler
    static var plate: Font { .system(size: 24, weight: .bold, design: .monospaced) }
    static var amount: Font { .system(size: 20, weight: .semibold, design: .default) }
    static var amountLarge: Font { .system(size: 32, weight: .light, design: .default) }
}

// MARK: - SwiftUI View Modifiers
struct HeroNumberModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .light, design: .default))
    }
}

struct PlateTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .tracking(2)
    }
}

extension View {
    func heroNumberStyle() -> some View {
        modifier(HeroNumberModifier())
    }

    func plateTextStyle() -> some View {
        modifier(PlateTextModifier())
    }
}
