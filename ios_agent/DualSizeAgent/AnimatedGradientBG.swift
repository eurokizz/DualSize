import SwiftUI

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(hex: "07070F")
                .ignoresSafeArea()
            
            // Ambient orbs — like in macOS Sequoia
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "007AFF").opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 560, height: 560)
                .offset(x: animate ? -120 : -80, y: animate ? -300 : -260)
                .blur(radius: 2)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "5856D6").opacity(0.14), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .offset(x: animate ? 140 : 100, y: animate ? 200 : 160)
                .blur(radius: 2)
                .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true), value: animate)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "30D158").opacity(0.08), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: animate ? -60 : 60, y: animate ? 400 : 380)
                .blur(radius: 2)
                .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: animate)
            
            // Noise texture overlay
            Rectangle()
                .fill(.clear)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}
