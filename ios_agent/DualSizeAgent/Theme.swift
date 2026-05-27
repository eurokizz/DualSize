import SwiftUI

// MARK: - Theme

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - DS Color Palette

enum DSColor {
    static let background     = Color(hex: "07070F")
    static let surfaceGlass   = Color.white.opacity(0.06)
    static let primary        = Color(hex: "007AFF")
    static let primaryLight   = Color(hex: "5AC8FA")
    static let success        = Color(hex: "34C759")
    static let warning        = Color(hex: "FF9500")
    static let destructive    = Color(hex: "FF3B30")
    static let purple         = Color(hex: "AF52DE")
    static let teal           = Color(hex: "5AC8FA")
    static let indigo         = Color(hex: "5856D6")
    
    static let textPrimary    = Color.white
    static let textSecondary  = Color.white.opacity(0.6)
    static let textTertiary   = Color.white.opacity(0.35)
    
    static let borderSubtle   = Color.white.opacity(0.08)
    static let borderMedium   = Color.white.opacity(0.15)
    static let borderStrong   = Color.white.opacity(0.25)
}

// MARK: - DS Typography

enum DSFont {
    static func largeTitle()  -> Font { .system(size: 34, weight: .bold,     design: .default) }
    static func title1()      -> Font { .system(size: 28, weight: .bold,     design: .default) }
    static func title2()      -> Font { .system(size: 22, weight: .bold,     design: .default) }
    static func title3()      -> Font { .system(size: 20, weight: .semibold, design: .default) }
    static func headline()    -> Font { .system(size: 17, weight: .semibold, design: .default) }
    static func body()        -> Font { .system(size: 17, weight: .regular,  design: .default) }
    static func callout()     -> Font { .system(size: 16, weight: .regular,  design: .default) }
    static func subheadline() -> Font { .system(size: 15, weight: .regular,  design: .default) }
    static func footnote()    -> Font { .system(size: 13, weight: .regular,  design: .default) }
    static func caption1()    -> Font { .system(size: 12, weight: .regular,  design: .default) }
    static func caption2()    -> Font { .system(size: 11, weight: .regular,  design: .default) }
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - DS Spacing

enum DSSpacing {
    static let xxs: CGFloat  = 4
    static let xs: CGFloat   = 8
    static let sm: CGFloat   = 12
    static let md: CGFloat   = 16
    static let lg: CGFloat   = 20
    static let xl: CGFloat   = 24
    static let xxl: CGFloat  = 32
    static let xxxl: CGFloat = 48
}

// MARK: - DS Radius

enum DSRadius {
    static let sm:  CGFloat = 10
    static let md:  CGFloat = 14
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 26
    static let full: CGFloat = 999
}
