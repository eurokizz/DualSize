import SwiftUI
import ReplayKit

struct StreamView: View {
    @EnvironmentObject var streamingManager: StreamingManager
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var appeared = false
    @State private var showQualityPicker = false
    @State private var showCodecPicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 14) {
                        StreamControlCard()
                        QualitySettingsCard()
                        AdvancedStreamCard()
                        if streamingManager.isStreaming {
                            StreamStatsCard()
                        }
                        Spacer().frame(height: 90)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .opacity(appeared ? 1 : 0)
                }
            }
            .navigationTitle("Стриминг")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Stream Control Card

struct StreamControlCard: View {
    @EnvironmentObject var streamingManager: StreamingManager
    @EnvironmentObject var connectionManager: ConnectionManager

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                // Status header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Трансляция экрана")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Text(streamingManager.isStreaming ? "Активна" : "Остановлена")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()

                    // Static status indicator — no .repeatForever glow loop
                    ZStack {
                        Circle()
                            .fill(streamingManager.isStreaming ? Color(hex: "34C759") : Color(hex: "FF3B30"))
                            .frame(width: 40, height: 40)
                            .opacity(0.18)

                        Image(systemName: streamingManager.isStreaming ? "record.circle.fill" : "record.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(streamingManager.isStreaming ? Color(hex: "34C759") : Color(hex: "FF3B30"))
                    }
                }
                
                // Main action button
                Button {
                    HapticManager.shared.impact(style: .heavy)
                    if streamingManager.isStreaming {
                        streamingManager.stopStreaming()
                    } else {
                        if connectionManager.isConnected {
                            streamingManager.startStreaming()
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: streamingManager.isStreaming ? "stop.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text(streamingManager.isStreaming ? "Остановить трансляцию" : "Начать трансляцию")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Group {
                            if streamingManager.isStreaming {
                                LinearGradient(
                                    colors: [Color(hex: "FF3B30"), Color(hex: "FF6B6B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                LinearGradient(
                                    colors: connectionManager.isConnected
                                        ? [Color(hex: "34C759"), Color(hex: "30D158")]
                                        : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(
                        color: streamingManager.isStreaming
                            ? Color(hex: "FF3B30").opacity(0.4)
                            : Color(hex: "34C759").opacity(0.4),
                        radius: 15,
                        x: 0,
                        y: 6
                    )
                }
                .buttonStyle(.plain)
                .disabled(!connectionManager.isConnected && !streamingManager.isStreaming)
                
                if !connectionManager.isConnected {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "FF9500"))
                        Text("Сначала подключите DualSize на компьютере")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
        }
    }
}

// MARK: - Quality Settings Card

struct QualitySettingsCard: View {
    @EnvironmentObject var streamingManager: StreamingManager
    
    let qualityOptions = ["480p", "720p", "1080p", "4K", "Авто"]
    let fpsOptions = [30, 60]
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Label("Качество видео", systemImage: "video.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
                
                // Resolution picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Разрешение")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        ForEach(qualityOptions, id: \.self) { option in
                            Button {
                                HapticManager.shared.selection()
                                withAnimation(.spring(response: 0.3)) {
                                    streamingManager.selectedQuality = option
                                }
                            } label: {
                                Text(option)
                                    .font(.system(size: 13, weight: streamingManager.selectedQuality == option ? .bold : .regular))
                                    .foregroundStyle(streamingManager.selectedQuality == option ? .white : .white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(
                                        streamingManager.selectedQuality == option
                                            ? LinearGradient(colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")], startPoint: .leading, endPoint: .trailing)
                                            : LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.04)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider().background(.white.opacity(0.08))
                
                // FPS picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Частота кадров")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        ForEach(fpsOptions, id: \.self) { fps in
                            Button {
                                HapticManager.shared.selection()
                                withAnimation(.spring(response: 0.3)) {
                                    streamingManager.targetFPS = fps
                                }
                            } label: {
                                Text("\(fps) FPS")
                                    .font(.system(size: 14, weight: streamingManager.targetFPS == fps ? .bold : .regular))
                                    .foregroundStyle(streamingManager.targetFPS == fps ? .white : .white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        streamingManager.targetFPS == fps
                                            ? LinearGradient(colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")], startPoint: .leading, endPoint: .trailing)
                                            : LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.04)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider().background(.white.opacity(0.08))
                
                // Bitrate slider
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Битрейт")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(streamingManager.bitrate)) Mbps")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "007AFF"))
                    }
                    
                    Slider(value: $streamingManager.bitrate, in: 2...20, step: 1)
                        .tint(Color(hex: "007AFF"))
                }
            }
        }
    }
}

// MARK: - Advanced Stream Card

struct AdvancedStreamCard: View {
    @EnvironmentObject var streamingManager: StreamingManager
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Label("Расширенные настройки", systemImage: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
                
                GlassToggle(
                    isOn: $streamingManager.hardwareAcceleration,
                    title: "Аппаратное ускорение",
                    subtitle: "VideoToolbox H.264/HEVC",
                    icon: "cpu",
                    iconColor: Color(hex: "AF52DE")
                )
                
                Divider().background(.white.opacity(0.08))
                
                GlassToggle(
                    isOn: $streamingManager.audioEnabled,
                    title: "Захват звука",
                    subtitle: "Аудио приложения + микрофон",
                    icon: "waveform",
                    iconColor: Color(hex: "FF9500")
                )
                
                Divider().background(.white.opacity(0.08))
                
                GlassToggle(
                    isOn: $streamingManager.gyroEnabled,
                    title: "Данные гироскопа",
                    subtitle: "Автоповорот на десктопе",
                    icon: "gyroscope",
                    iconColor: Color(hex: "34C759")
                )
                
                Divider().background(.white.opacity(0.08))
                
                // Codec selector
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "film.stack")
                            .foregroundStyle(Color(hex: "5AC8FA"))
                        Text("Кодек")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(streamingManager.selectedCodec)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "007AFF"))
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(["H.264", "H.265", "Авто"], id: \.self) { codec in
                            Button {
                                HapticManager.shared.selection()
                                streamingManager.selectedCodec = codec
                            } label: {
                                Text(codec)
                                    .font(.system(size: 12, weight: streamingManager.selectedCodec == codec ? .bold : .regular))
                                    .foregroundStyle(streamingManager.selectedCodec == codec ? .white : .white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 34)
                                    .background(
                                        streamingManager.selectedCodec == codec
                                            ? Color(hex: "5AC8FA").opacity(0.25)
                                            : Color.white.opacity(0.06)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                                            .strokeBorder(
                                                streamingManager.selectedCodec == codec
                                                    ? Color(hex: "5AC8FA").opacity(0.5)
                                                    : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stream Stats Card

struct StreamStatsCard: View {
    @EnvironmentObject var streamingManager: StreamingManager
    @State private var chartValues: [Double] = Array(repeating: 0, count: 30)
    @State private var timer: Timer?
    
    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("Статистика в реальном времени")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text("30с")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                // Mini bar chart for FPS
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(Array(chartValues.enumerated()), id: \.offset) { i, value in
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: max(4, value * 50))
                            .opacity(0.4 + (Double(i) / Double(chartValues.count)) * 0.6)
                    }
                }
                .frame(height: 50)
                .animation(.easeInOut(duration: 0.3), value: chartValues)
                
                HStack {
                    Label("Сброшено пакетов: \(streamingManager.droppedPackets)", systemImage: "arrow.down.right.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Label("Переданы: \(streamingManager.totalMBTransferred) МБ", systemImage: "arrow.up.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                let newValue = Double.random(in: 0.6...1.0)
                chartValues.removeFirst()
                chartValues.append(newValue)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}
