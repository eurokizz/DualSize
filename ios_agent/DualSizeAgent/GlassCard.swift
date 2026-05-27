import SwiftUI

// MARK: - Glass Card

struct GlassCard<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Inner top highlight
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.07), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.20),
                                    .white.opacity(0.05),
                                    .clear,
                                    .white.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
