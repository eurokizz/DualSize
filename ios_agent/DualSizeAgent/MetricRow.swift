import SwiftUI

// MARK: - Metric Row

struct MetricRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.6))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}
