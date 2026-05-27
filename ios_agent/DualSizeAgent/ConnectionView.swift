import SwiftUI

// MARK: - Connection View (Scan / Search for Desktop)

struct ConnectionView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var appeared = false
    @State private var scanAngle: Double = 0
    @State private var nearbyDevices: [NearbyDevice] = []
    @State private var isScanning = false
    @State private var scanTimer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Radar Scanner
                        RadarView(isActive: isScanning)
                            .frame(width: 220, height: 220)
                            .padding(.top, 20)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.8)
                        
                        // Status text
                        VStack(spacing: 6) {
                            Text(isScanning ? "Поиск устройств..." : "Нажмите для сканирования")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("USB · Wi-Fi · Bonjour")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .opacity(appeared ? 1 : 0)
                        
                        // Scan Button
                        Button {
                            toggleScan()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: isScanning ? "stop.fill" : "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(isScanning ? "Остановить" : "Начать сканирование")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: isScanning
                                        ? [Color(hex: "FF3B30"), Color(hex: "FF6B6B")]
                                        : [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(
                                color: (isScanning ? Color(hex: "FF3B30") : Color(hex: "007AFF")).opacity(0.4),
                                radius: 16, x: 0, y: 6
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        
                        // Nearby devices
                        if !nearbyDevices.isEmpty {
                            GlassCard {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("Найденные устройства")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(.white.opacity(0.5))
                                        Spacer()
                                        Text("\(nearbyDevices.count)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Color(hex: "007AFF"))
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color(hex: "007AFF").opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                    .padding(.bottom, 14)
                                    
                                    ForEach(Array(nearbyDevices.enumerated()), id: \.element.id) { i, device in
                                        if i > 0 { Divider().background(.white.opacity(0.08)).padding(.vertical, 8) }
                                        
                                        Button {
                                            HapticManager.shared.impact(style: .medium)
                                            connectionManager.startDiscovery()
                                        } label: {
                                            HStack(spacing: 14) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .fill(Color(hex: "007AFF").opacity(0.15))
                                                        .frame(width: 40, height: 40)
                                                    Image(systemName: device.icon)
                                                        .font(.system(size: 18))
                                                        .foregroundStyle(Color(hex: "007AFF"))
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(device.name)
                                                        .font(.system(size: 15, weight: .semibold))
                                                        .foregroundStyle(.white)
                                                    Text(device.subtitle)
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(.white.opacity(0.4))
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing, spacing: 3) {
                                                    Text(device.signalStrength)
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(device.signalColor)
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 11))
                                                        .foregroundStyle(.white.opacity(0.25))
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        // Manual IP entry
                        ManualIPCard()
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                            .animation(.spring(response: 0.6).delay(0.2), value: appeared)
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationTitle("Подключение")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
        .onDisappear {
            scanTimer?.invalidate()
        }
    }
    
    private func toggleScan() {
        HapticManager.shared.impact(style: .medium)
        isScanning.toggle()
        
        if isScanning {
            simulateDiscovery()
        } else {
            scanTimer?.invalidate()
            nearbyDevices.removeAll()
        }
    }
    
    private func simulateDiscovery() {
        // Demo devices (real impl uses NWBrowser)
        let demos: [NearbyDevice] = [
            NearbyDevice(name: "DESKTOP-FL23", subtitle: "Windows 11 · DualSize 1.0", icon: "desktopcomputer", signalStrength: "USB", signalColor: Color(hex: "34C759")),
            NearbyDevice(name: "MacBook-Pro-Work", subtitle: "macOS Sequoia · Wi-Fi", icon: "laptopcomputer", signalStrength: "Wi-Fi", signalColor: Color(hex: "007AFF")),
        ]
        
        scanTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { _ in
            withAnimation(.spring(response: 0.5)) {
                nearbyDevices = demos
            }
        }
    }
}

struct NearbyDevice: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let icon: String
    let signalStrength: String
    let signalColor: Color
}

// MARK: - Radar View

struct RadarView: View {
    let isActive: Bool
    @State private var rotation: Double = 0
    @State private var rings: [Double] = [0, 0, 0]
    
    var body: some View {
        ZStack {
            // Rings
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(
                        Color(hex: "007AFF").opacity(0.15 - Double(i) * 0.04),
                        lineWidth: 1
                    )
                    .frame(width: 80 + CGFloat(i) * 46, height: 80 + CGFloat(i) * 46)
            }
            
            // Scan pulse rings
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(Color(hex: "007AFF").opacity(1 - rings[i]), lineWidth: 1.5)
                    .frame(
                        width: 40 + rings[i] * 180,
                        height: 40 + rings[i] * 180
                    )
                    .opacity(isActive ? 1 : 0)
            }
            
            // Sweep line
            if isActive {
                ZStack(alignment: .center) {
                    // Conic gradient sweep
                    Circle()
                        .trim(from: 0, to: 0.25)
                        .fill(
                            AngularGradient(
                                colors: [.clear, Color(hex: "007AFF").opacity(0.3)],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(90)
                            )
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(rotation))
                    
                    // Sweep arm
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color(hex: "007AFF").opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 90, height: 1.5)
                        .offset(x: 45)
                        .rotationEffect(.degrees(rotation))
                }
            }
            
            // Center dot
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA").opacity(0.5)],
                        center: .center, startRadius: 0, endRadius: 12
                    )
                )
                .frame(width: 24, height: 24)
                .shadow(color: Color(hex: "007AFF").opacity(0.8), radius: 10)
            
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
        }
        .onChange(of: isActive) { _, active in
            if active {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                animateRings()
            } else {
                rotation = 0
            }
        }
    }
    
    private func animateRings() {
        for i in 0..<3 {
            let delay = Double(i) * 0.8
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                    rings[i] = 1.0
                }
            }
        }
    }
}

// MARK: - Manual IP Card

struct ManualIPCard: View {
    @State private var ipText = ""
    @State private var portText = "9090"
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("ПРЯМОЕ ПОДКЛЮЧЕНИЕ")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.35))
                        .tracking(1.5)
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    TextField("192.168.1.100", text: $ipText)
                        .keyboardType(.numbersAndPunctuation)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    Text(":")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(.white.opacity(0.3))
                    
                    TextField("9090", text: $portText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(.white)
                        .frame(width: 70)
                        .padding(10)
                        .background(.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        )
                }
                
                Button {
                    HapticManager.shared.impact(style: .medium)
                    connectionManager.startDiscovery()
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Подключиться")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundStyle(.white)
                    .background(Color(hex: "007AFF").opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(Color(hex: "007AFF").opacity(0.4), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(ipText.isEmpty)
                .opacity(ipText.isEmpty ? 0.4 : 1)
            }
        }
    }
}
