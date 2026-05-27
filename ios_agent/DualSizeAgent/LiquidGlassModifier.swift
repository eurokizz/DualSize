import SwiftUI

// MARK: - Liquid Glass Modifier (iOS 26 compatible)

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var intensity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.08 * intensity),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.22 * intensity),
                                    .white.opacity(0.06 * intensity),
                                    .clear,
                                    .white.opacity(0.04 * intensity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.3 * intensity), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, intensity: Double = 1.0) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, intensity: intensity))
    }
}

// MARK: - Specular Highlight Modifier

struct SpecularHighlightModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: 80, height: 40)
                    .offset(x: 10, y: 6)
                    .blur(radius: 8)
                    .allowsHitTesting(false)
            }
    }
}

extension View {
    func specularHighlight(cornerRadius: CGFloat = 20) -> some View {
        modifier(SpecularHighlightModifier(cornerRadius: cornerRadius))
    }
}
