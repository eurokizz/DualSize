import SwiftUI
import Network

struct StatusView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var streamingManager: StreamingManager
    @EnvironmentObject var batteryMonitor: BatteryMonitor
    @State private var animateGlow = false
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Connection Status Card
                        ConnectionStatusCard()
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 30)
                        
                        // Streaming Metrics
                        if connectionManager.isConnected {
                            StreamMetricsCard()
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 30)
                                .animation(.spring(response: 0.6).delay(0.1), value: appeared)
                        }
                        
                        // Device Info Card
                        DeviceInfoCard()
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 30)
                            .animation(.spring(response: 0.6).delay(0.15), value: appeared)
                        
                        // Quick Actions
                        QuickActionsCard()
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 30)
                            .animation(.spring(response: 0.6).delay(0.2), value: appeared)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("DualSize")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.impact(style: .medium)
                        connectionManager.startDiscovery()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(hex: "007AFF"))
                            .rotationEffect(.degrees(animateGlow ? 360 : 0))
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Connection Status Card

struct ConnectionStatusCard: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var pulseAnimation = false
    
    var statusColor: Color {
        switch connectionManager.connectionState {
        case .connected: return Color(hex: "34C759")
        case .connecting: return Color(hex: "FF9500")
        case .pairing: return Color(hex: "007AFF")
        case .disconnected: return Color(hex: "FF3B30")
        }
    }
    
    var statusIcon: String {
        switch connectionManager.connectionState {
        case .connected: return "checkmark.circle.fill"
        case .connecting: return "arrow.triangle.2.circlepath"
        case .pairing: return "lock.open.fill"
        case .disconnected: return "xmark.circle.fill"
        }
    }
    
    var statusText: String {
        switch connectionManager.connectionState {
        case .connected: return "Подключено"
        case .connecting: return "Подключение..."
        case .pairing: return "Сопряжение..."
        case .disconnected: return "Не подключено"
        }
    }
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Статус соединения")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(statusColor.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                                    .opacity(pulseAnimation ? 0 : 0.6)
                                
                                Image(systemName: statusIcon)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(statusColor)
                            }
                            
                            Text(statusText)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Connection type badge
                    if connectionManager.isConnected {
                        VStack(spacing: 4) {
                            Image(systemName: connectionManager.connectionType == .usb ? "cable.connector" : "wifi")
                                .font(.system(size: 22))
                                .foregroundStyle(Color(hex: "007AFF"))
                            
                            Text(connectionManager.connectionType == .usb ? "USB" : "Wi-Fi")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(12)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                
                if connectionManager.isConnected, let deviceName = connectionManager.connectedDeviceName {
                    Divider()
                        .background(.white.opacity(0.1))
                    
                    HStack {
                        Image(systemName: "iphone")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "5AC8FA"))
                        Text(deviceName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Text(connectionManager.connectedDeviceModel ?? "")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                
                if !connectionManager.isConnected {
                    Button {
                        HapticManager.shared.impact(style: .medium)
                        connectionManager.startDiscovery()
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Найти устройство")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Stream Metrics Card

struct StreamMetricsCard: View {
    @EnvironmentObject var streamingManager: StreamingManager
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Производительность")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    
                    // Live indicator
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(hex: "FF3B30"))
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "FF3B30"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FF3B30").opacity(0.15))
                    .clipShape(Capsule())
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricTile(
                        value: "\(streamingManager.currentFPS)",
                        unit: "FPS",
                        icon: "film.stack",
                        color: Color(hex: "34C759")
                    )
                    MetricTile(
                        value: "\(streamingManager.latencyMs)",
                        unit: "ms",
                        icon: "bolt.fill",
                        color: Color(hex: "FF9500")
                    )
                    MetricTile(
                        value: streamingManager.bitrateString,
                        unit: "Mbps",
                        icon: "arrow.up.arrow.down",
                        color: Color(hex: "007AFF")
                    )
                    MetricTile(
                        value: streamingManager.resolutionString,
                        unit: "px",
                        icon: "rectangle.on.rectangle",
                        color: Color(hex: "AF52DE")
                    )
                }
            }
        }
    }
}

struct MetricTile: View {
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(12)
        .background(color.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Device Info Card

struct DeviceInfoCard: View {
    @EnvironmentObject var batteryMonitor: BatteryMonitor
    
    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("Устройство")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
                
                MetricRow(
                    icon: "iphone.gen3",
                    iconColor: Color(hex: "007AFF"),
                    label: "Модель",
                    value: DeviceIdentifier.shared.modelName
                )
                
                Divider().background(.white.opacity(0.08))
                
                MetricRow(
                    icon: "cpu",
                    iconColor: Color(hex: "AF52DE"),
                    label: "iOS версия",
                    value: UIDevice.current.systemVersion
                )
                
                Divider().background(.white.opacity(0.08))
                
                MetricRow(
                    icon: "battery.100percent",
                    iconColor: batteryMonitor.batteryLevel > 0.2 ? Color(hex: "34C759") : Color(hex: "FF3B30"),
                    label: "Батарея",
                    value: "\(Int(batteryMonitor.batteryLevel * 100))% · \(batteryMonitor.isCharging ? "Зарядка" : "Отключено")"
                )
                
                Divider().background(.white.opacity(0.08))
                
                MetricRow(
                    icon: "network",
                    iconColor: Color(hex: "34C759"),
                    label: "IP адрес",
                    value: connectionManager_ip()
                )
            }
        }
    }
    
    func connectionManager_ip() -> String {
        var address: String = "Нет"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: (interface?.ifa_name)!)
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}

// MARK: - Quick Actions Card

struct QuickActionsCard: View {
    @EnvironmentObject var streamingManager: StreamingManager
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("Быстрые действия")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    QuickActionButton(
                        icon: streamingManager.isStreaming ? "stop.fill" : "play.fill",
                        label: streamingManager.isStreaming ? "Остановить" : "Начать стрим",
                        color: streamingManager.isStreaming ? Color(hex: "FF3B30") : Color(hex: "34C759"),
                        action: {
                            if streamingManager.isStreaming {
                                streamingManager.stopStreaming()
                            } else {
                                streamingManager.startStreaming()
                            }
                        }
                    )
                    
                    QuickActionButton(
                        icon: "camera.fill",
                        label: "Скриншот",
                        color: Color(hex: "007AFF"),
                        action: { streamingManager.requestScreenshot() }
                    )
                    
                    QuickActionButton(
                        icon: "gyroscope",
                        label: "Гироскоп",
                        color: Color(hex: "AF52DE"),
                        action: { }
                    )
                    
                    QuickActionButton(
                        icon: "xmark.circle.fill",
                        label: "Отключить",
                        color: Color(hex: "FF9500"),
                        action: { connectionManager.disconnect() }
                    )
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .medium)
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(color)
                }
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(isPressed ? 0.94 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeIn(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3)) { isPressed = false } }
        )
    }
}
