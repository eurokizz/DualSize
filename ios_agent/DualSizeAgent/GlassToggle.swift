import SwiftUI

// MARK: - Glass Toggle

struct GlassToggle: View {
    @Binding var isOn: Bool
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(isOn ? 0.2 : 0.08))
                    .frame(width: 36, height: 36)
                    .animation(.easeInOut(duration: 0.2), value: isOn)
                
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(isOn ? iconColor : iconColor.opacity(0.4))
                    .animation(.easeInOut(duration: 0.2), value: isOn)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(iconColor)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.impact(style: .light)
            withAnimation(.spring(response: 0.3)) {
                isOn.toggle()
            }
        }
    }
}
