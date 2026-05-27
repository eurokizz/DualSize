import SwiftUI
import AVFoundation
import Network

struct SettingsView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var streamingManager: StreamingManager
    @State private var appeared = false
    @State private var showPairingView = false
    @State private var showAbout = false
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("autoConnect") private var autoConnect = true
    @AppStorage("keepScreenOn") private var keepScreenOn = true
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("apiPort") private var apiPort = 9090
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Profile Card
                        ProfileCard()
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 30)
                        
                        // Connection settings
                        GlassCard {
                            VStack(spacing: 16) {
                                SettingsSectionHeader(title: "Подключение", icon: "antenna.radiowaves.left.and.right")
                                
                                GlassToggle(
                                    isOn: $autoConnect,
                                    title: "Автоподключение",
                                    subtitle: "Автоматически к последнему устройству",
                                    icon: "link",
                                    iconColor: Color(hex: "34C759")
                                )
                                
                                Divider().background(.white.opacity(0.08))
                                
                                NavigationLink {
                                    PairingCodeView()
                                } label: {
                                    SettingsRowArrow(
                                        icon: "qrcode",
                                        iconColor: Color(hex: "007AFF"),
                                        title: "Сопряжение устройств",
                                        subtitle: "Показать код для ПК"
                                    )
                                }
                                
                                Divider().background(.white.opacity(0.08))
                                
                                // Port setting
                                HStack {
                                    Image(systemName: "network")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(hex: "5AC8FA"))
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Порт API Gateway")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.white)
                                        Text("localhost:\(apiPort)")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.white.opacity(0.4))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(apiPort)")
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundStyle(Color(hex: "007AFF"))
                                }
                                
                                Divider().background(.white.opacity(0.08))
                                
                                NavigationLink {
                                    TrustedDevicesView()
                                } label: {
                                    SettingsRowArrow(
                                        icon: "checkmark.shield.fill",
                                        iconColor: Color(hex: "34C759"),
                                        title: "Доверенные устройства",
                                        subtitle: "\(connectionManager.trustedDevices.count) устройств"
                                    )
                                }
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.spring(response: 0.6).delay(0.1), value: appeared)
                        
                        // Display settings
                        GlassCard {
                            VStack(spacing: 16) {
                                SettingsSectionHeader(title: "Отображение", icon: "display")
                                
                                GlassToggle(
                                    isOn: $keepScreenOn,
                                    title: "Не выключать экран",
                                    subtitle: "Пока активен стриминг",
                                    icon: "sun.max.fill",
                                    iconColor: Color(hex: "FF9500")
                                )
                                .onChange(of: keepScreenOn) { _, val in
                                    UIApplication.shared.isIdleTimerDisabled = val
                                }
                                
                                Divider().background(.white.opacity(0.08))
                                
                                GlassToggle(
                                    isOn: $hapticEnabled,
                                    title: "Тактильный отклик",
                                    subtitle: "Вибрация при действиях",
                                    icon: "waveform.path",
                                    iconColor: Color(hex: "AF52DE")
                                )
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.spring(response: 0.6).delay(0.15), value: appeared)
                        
                        // Streaming settings
                        GlassCard {
                            VStack(spacing: 16) {
                                SettingsSectionHeader(title: "Стриминг", icon: "video.fill")
                                
                                GlassToggle(
                                    isOn: $streamingManager.startOnConnection,
                                    title: "Авто-старт стрима",
                                    subtitle: "Начинать при подключении",
                                    icon: "play.circle.fill",
                                    iconColor: Color(hex: "34C759")
                                )
                                
                                Divider().background(.white.opacity(0.08))
                                
                                GlassToggle(
                                    isOn: $streamingManager.gyroEnabled,
                                    title: "Данные гироскопа",
                                    subtitle: "Автоповорот на десктопе",
                                    icon: "gyroscope",
                                    iconColor: Color(hex: "5AC8FA")
                                )
                                
                                Divider().background(.white.opacity(0.08))
                                
                                GlassToggle(
                                    isOn: $streamingManager.audioEnabled,
                                    title: "Передача звука",
                                    subtitle: "Захват аудио приложений",
                                    icon: "speaker.wave.3.fill",
                                    iconColor: Color(hex: "FF9500")
                                )
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.spring(response: 0.6).delay(0.2), value: appeared)
                        
                        // About & Support
                        GlassCard {
                            VStack(spacing: 14) {
                                SettingsSectionHeader(title: "О программе", icon: "info.circle.fill")
                                
                                NavigationLink {
                                    AboutView()
                                } label: {
                                    SettingsRowArrow(
                                        icon: "app.fill",
                                        iconColor: Color(hex: "007AFF"),
                                        title: "DualSize Agent",
                                        subtitle: "Версия 1.0.0 (1)"
                                    )
                                }
                                
                                Divider().background(.white.opacity(0.08))
                                
                                Button {
                                    // Open GitHub
                                    if let url = URL(string: "https://github.com/FL-corp/DualSize") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                                            .font(.system(size: 18))
                                            .foregroundStyle(.white)
                                            .frame(width: 32, height: 32)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("GitHub репозиторий")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("FL-corp/DualSize")
                                                .font(.system(size: 12))
                                                .foregroundStyle(.white.opacity(0.4))
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Divider().background(.white.opacity(0.08))
                                
                                Button(role: .destructive) {
                                    HapticManager.shared.notification(type: .warning)
                                    connectionManager.resetAllSettings()
                                } label: {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color(hex: "FF3B30"))
                                            .frame(width: 32, height: 32)
                                            .background(Color(hex: "FF3B30").opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        
                                        Text("Сбросить настройки")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(Color(hex: "FF3B30"))
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.spring(response: 0.6).delay(0.25), value: appeared)
                        
                        // Footer
                        VStack(spacing: 4) {
                            Text("DualSize Agent v1.0.0")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.3))
                            Text("© 2025 FeelAre Corp. MIT License")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.2))
                        }
                        .padding(.vertical, 8)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut.delay(0.3), value: appeared)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.1)) {
                appeared = true
            }
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        }
    }
}

// MARK: - Profile Card

struct ProfileCard: View {
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    Image(systemName: "rectangle.on.rectangle")
                        .font(.system(size: 26, weight: .light))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("DualSize Agent")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    Text("FeelAre Corp · v1.0.0")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "34C759"))
                            .frame(width: 6, height: 6)
                        Text("Агент активен")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "34C759"))
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Settings Helpers

struct SettingsSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1.0)
            Spacer()
        }
    }
}

struct SettingsRowArrow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
}

// MARK: - Trusted Devices View

struct TrustedDevicesView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            if connectionManager.trustedDevices.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 56))
                        .foregroundStyle(.white.opacity(0.2))
                    Text("Нет доверенных устройств")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Подключите ПК с DualSize для добавления")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                }
            } else {
                List {
                    ForEach(connectionManager.trustedDevices, id: \.self) { device in
                        HStack {
                            Image(systemName: "desktopcomputer")
                                .foregroundStyle(Color(hex: "007AFF"))
                            Text(device)
                                .foregroundStyle(.white)
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .onDelete { indexSet in
                        connectionManager.trustedDevices.remove(atOffsets: indexSet)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Доверенные")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color(hex: "007AFF").opacity(0.5), radius: 20)
                        
                        Image(systemName: "rectangle.on.rectangle")
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 6) {
                        Text("DualSize Agent")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Версия 1.0.0 (1)")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("FeelAre Corp · 2025")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    
                    GlassCard {
                        VStack(spacing: 12) {
                            Text("DualSize — это профессиональная система зеркалирования iOS-устройств. Используется для разработки, тестирования, дистанционного управления и интеграции с IDE.")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        Text("Разработано с ❤️ на Swift")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("MIT License · Open Source")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.25))
                    }
                    
                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("О программе")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
    }
}
