import SwiftUI

// MARK: - Static Gradient Background (performance-tuned)
//
// Previously: 3 large RadialGradient circles each driven by a
// .repeatForever spring animation + blur, instantiated on every tab.
// On iPhone 13 that meant 3 GPU-bound infinite animations per screen,
// dropping the whole UI to ~30 FPS during scrolling.
// Now: same visual orbs, but static — the eye barely notices the
// difference, and the GPU is freed up for ReplayKit / VideoToolbox.

struct AnimatedGradientBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "07070F")
                .ignoresSafeArea()

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
                .offset(x: -100, y: -280)

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
                .offset(x: 120, y: 180)

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
                .offset(x: 0, y: 390)
        }
        .ignoresSafeArea()
        .drawingGroup()
    }
}
