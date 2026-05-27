import SwiftUI

// MARK: - Status Indicator

struct StatusIndicator: View {
    let isActive: Bool
    let label: String
    var size: CGFloat = 8
    
    @State private var pulse = false
    
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                if isActive {
                    Circle()
                        .fill(Color(hex: "34C759").opacity(0.3))
                        .frame(width: size * 2.5, height: size * 2.5)
                        .scaleEffect(pulse ? 1.4 : 1.0)
                        .opacity(pulse ? 0 : 1)
                }
                Circle()
                    .fill(isActive ? Color(hex: "34C759") : Color(hex: "FF3B30"))
                    .frame(width: size, height: size)
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .onAppear {
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}
