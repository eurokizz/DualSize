import SwiftUI

// MARK: - Pairing Code View

struct PairingCodeView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var pairingCode: String = ""
    @State private var timeRemaining: Int = 900
    @State private var timer: Timer?
    @State private var appeared = false
    @State private var codeReveal = false
    @State private var qrOpacity = 0.0
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    // Header
                    VStack(spacing: 10) {
                        // Custom lock icon
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle().strokeBorder(.white.opacity(0.15), lineWidth: 1)
                                )
                            
                            DSIcon.pairing
                                .resizable()
                                .scaledToFit()
                                .frame(width: 38, height: 38)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .scaleEffect(appeared ? 1 : 0.7)
                        .opacity(appeared ? 1 : 0)
                        
                        Text("Сопряжение устройства")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)
                        
                        Text("Введите этот код в приложении DualSize на компьютере")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                    }
                    .padding(.top, 20)
                    
                    // Code Card
                    GlassCard {
                        VStack(spacing: 20) {
                            
                            // Timer
                            HStack {
                                Image(systemName: "timer")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.4))
                                Text("Истекает через \(formatTime(timeRemaining))")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.4))
                                Spacer()
                                
                                // Progress arc
                                Circle()
                                    .trim(from: 0, to: CGFloat(timeRemaining) / 900)
                                    .stroke(
                                        LinearGradient(
                                            colors: timeRemaining > 300
                                                ? [Color(hex: "007AFF"), Color(hex: "5AC8FA")]
                                                : [Color(hex: "FF9500"), Color(hex: "FF3B30")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                    )
                                    .frame(width: 24, height: 24)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1), value: timeRemaining)
                            }
                            
                            // Code display
                            HStack(spacing: 12) {
                                CodeBlock(chars: pairingCode.isEmpty ? "XXXX" : String(pairingCode.prefix(4)))
                                
                                Text("—")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundStyle(.white.opacity(0.3))
                                
                                CodeBlock(chars: pairingCode.count >= 8 ? String(pairingCode.suffix(4)) : "XXXX")
                            }
                            .scaleEffect(codeReveal ? 1 : 0.8)
                            .opacity(codeReveal ? 1 : 0)
                            
                            // Copy button
                            Button {
                                UIPasteboard.general.string = formatCode(pairingCode)
                                HapticManager.shared.notification(type: .success)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 14))
                                    Text("Скопировать код")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(Color(hex: "007AFF"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(hex: "007AFF").opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                                        .strokeBorder(Color(hex: "007AFF").opacity(0.3), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.6).delay(0.15), value: appeared)
                    
                    // QR Code placeholder card
                    GlassCard {
                        VStack(spacing: 16) {
                            HStack {
                                Text("QR-код")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.5))
                                Spacer()
                                Text("Наведите камеру на ПК")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            
                            // QR placeholder with pattern
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.white)
                                    .frame(width: 180, height: 180)
                                
                                // QR pattern simulation
                                QRPatternView()
                                    .frame(width: 160, height: 160)
                            }
                            .opacity(qrOpacity)
                            .animation(.easeIn(duration: 0.5).delay(0.3), value: qrOpacity)
                            
                            Text("Отсканируйте для подключения без ввода кода")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.25), value: appeared)
                    
                    // Instructions
                    GlassCard {
                        VStack(spacing: 14) {
                            HStack {
                                Text("КАК ПОДКЛЮЧИТЬ")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.35))
                                    .tracking(1.5)
                                Spacer()
                            }
                            
                            InstructionRow(number: "1", text: "Откройте DualSize на Windows / Linux")
                            InstructionRow(number: "2", text: "Нажмите «Подключить устройство» в приложении")
                            InstructionRow(number: "3", text: "Введите код или отсканируйте QR-код выше")
                            InstructionRow(number: "4", text: "Подтвердите подключение на этом экране")
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.3), value: appeared)
                    
                    // Regenerate button
                    Button {
                        HapticManager.shared.impact(style: .medium)
                        generateCode()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Новый код")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.35), value: appeared)
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Сопряжение")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            generateCode()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
            withAnimation(.spring(response: 0.6).delay(0.4)) {
                codeReveal = true
            }
            qrOpacity = 1
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func generateCode() {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        pairingCode = String((0..<8).map { _ in chars.randomElement()! })
        timeRemaining = 900
        withAnimation(.spring(response: 0.4)) {
            codeReveal = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.5)) {
                codeReveal = true
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                generateCode()
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
    
    private func formatCode(_ code: String) -> String {
        guard code.count == 8 else { return code }
        return "\(code.prefix(4))-\(code.suffix(4))"
    }
}

// MARK: - Code Block

struct CodeBlock: View {
    let chars: String
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(chars.enumerated()), id: \.offset) { _, char in
                Text(String(char))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                            )
                    )
            }
        }
    }
}

// MARK: - QR Pattern View

struct QRPatternView: View {
    var body: some View {
        Canvas { ctx, size in
            let cellSize: CGFloat = 10
            let cols = Int(size.width / cellSize)
            let rows = Int(size.height / cellSize)
            
            // Seed for deterministic pattern
            var seed: UInt64 = 0x4475616C53697A65
            
            for row in 0..<rows {
                for col in 0..<cols {
                    seed = seed &* 6364136223846793005 &+ 1442695040888963407
                    let filled = (seed >> 33) % 2 == 0
                    
                    if filled {
                        let rect = CGRect(
                            x: CGFloat(col) * cellSize + 1,
                            y: CGFloat(row) * cellSize + 1,
                            width: cellSize - 2,
                            height: cellSize - 2
                        )
                        ctx.fill(Path(rect), with: .color(.black))
                    }
                }
            }
            
            // Corner markers
            let markerSize: CGFloat = 30
            for (x, y) in [(0.0, 0.0), (size.width - markerSize, 0.0), (0.0, size.height - markerSize)] {
                let outer = CGRect(x: x, y: y, width: markerSize, height: markerSize)
                ctx.fill(Path(outer), with: .color(.black))
                let inner = CGRect(x: x + 4, y: y + 4, width: markerSize - 8, height: markerSize - 8)
                ctx.fill(Path(inner), with: .color(.white))
                let center = CGRect(x: x + 8, y: y + 8, width: markerSize - 16, height: markerSize - 16)
                ctx.fill(Path(center), with: .color(.black))
            }
        }
    }
}

// MARK: - Instruction Row

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
        }
    }
}

// MARK: - DSIcon (Custom Icons via SF Symbols customization)

enum DSIcon {
    static var pairing: Image { Image(systemName: "lock.open.rotation") }
    static var stream: Image { Image(systemName: "video.badge.waveform.fill") }
    static var location: Image { Image(systemName: "location.viewfinder") }
    static var settings: Image { Image(systemName: "gearshape.2.fill") }
    static var connection: Image { Image(systemName: "point.3.connected.trianglepath.dotted") }
    static var security: Image { Image(systemName: "checkerboard.shield") }
    static var performance: Image { Image(systemName: "chart.bar.xaxis.ascending.badge.clock") }
    static var screenshot: Image { Image(systemName: "viewfinder.rectangular") }
}
