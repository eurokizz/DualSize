import SwiftUI

// MARK: - Info View (Hotkeys Reference)

struct InfoView: View {
    @State private var appeared = false
    @State private var selectedSection = 0
    
    let sections = ["Горячие клавиши", "Протокол", "Безопасность"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                VStack(spacing: 0) {
                    // Segmented picker
                    Picker("Section", selection: $selectedSection) {
                        ForEach(Array(sections.enumerated()), id: \.offset) { i, s in
                            Text(s).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            switch selectedSection {
                            case 0: HotkeysSection()
                            case 1: ProtocolSection()
                            default: SecuritySection()
                            }
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Справка")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Hotkeys Section

struct HotkeysSection: View {
    let groups: [(String, [(String, String)])] = [
        ("Управление окном", [
            ("⌘ + Enter",          "Полноэкранный режим"),
            ("Esc",                 "Выйти из полноэкранного"),
            ("⌘ + W",              "Закрыть окно"),
            ("⌘ + M",              "Свернуть в Dock"),
            ("⌘ + ⌥ + F",         "Войти в Visor-режим"),
            ("⌘ + Shift + F",      "Floating-режим поверх"),
        ]),
        ("Устройство", [
            ("⌘ + R",              "Повернуть экран (90°)"),
            ("⌘ + Shift + H",      "Кнопка Home"),
            ("⌘ + Shift + L",      "Кнопка Lock"),
            ("⌘ + Shift + S",      "Скриншот устройства"),
            ("⌘ + Shift + R",      "Начать/остановить запись"),
            ("⌘ + Shift + V",      "Вставить текст с клипборда"),
        ]),
        ("Стриминг", [
            ("⌘ + P",              "Старт / Пауза стрима"),
            ("⌘ + Q",              "Отключиться"),
            ("⌘ + +",              "Увеличить масштаб"),
            ("⌘ + -",              "Уменьшить масштаб"),
            ("⌘ + 0",              "Масштаб 1:1"),
            ("⌘ + F",              "Вписать в окно"),
        ]),
        ("Ввод", [
            ("Клик мышью",         "Тап по экрану"),
            ("Клик + удержание",   "Долгий тап"),
            ("Перетаскивание",     "Свайп"),
            ("Колесо мыши",        "Скролл"),
            ("Ctrl + ⌥ + тап",     "3D Touch / Haptic Touch"),
            ("⌘ + Backspace",      "Очистить текущее поле"),
        ]),
    ]
    
    var body: some View {
        ForEach(groups, id: \.0) { group in
            GlassCard {
                VStack(spacing: 12) {
                    HStack {
                        Text(group.0.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1.2)
                        Spacer()
                    }
                    
                    ForEach(Array(group.1.enumerated()), id: \.offset) { i, item in
                        if i > 0 { Divider().background(.white.opacity(0.06)) }
                        
                        HStack {
                            Text(item.0)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color(hex: "5AC8FA"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(hex: "007AFF").opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .strokeBorder(Color(hex: "007AFF").opacity(0.25), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                .fixedSize()
                            
                            Spacer()
                            
                            Text(item.1)
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.65))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Protocol Section

struct ProtocolSection: View {
    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("ПРОТОКОЛ DSP 1.0")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(1.2)
                    Spacer()
                }
                
                ForEach(protocolItems, id: \.0) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Text(item.0)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: "FF9500"))
                            .frame(width: 80, alignment: .leading)
                        
                        Text(item.1)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    Divider().background(.white.opacity(0.06))
                }
            }
        }
        
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("ПОРТЫ")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(1.2)
                    Spacer()
                }
                
                ForEach(portItems, id: \.0) { item in
                    HStack {
                        Text(":\(item.0)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: "34C759"))
                        Spacer()
                        Text(item.1)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Divider().background(.white.opacity(0.06))
                }
            }
        }
    }
    
    let protocolItems = [
        ("handshake",     "Инициализация соединения с метаданными устройства"),
        ("ping/pong",     "Heartbeat каждые 5 секунд для контроля соединения"),
        ("frame",         "UDP-кадр видеопотока с RTP-заголовком и seq.номером"),
        ("touch",         "Событие тача с нормализованными координатами"),
        ("gyro",          "Данные гироскопа: pitch, roll, yaw, rotationRate"),
        ("location",      "Обновление GPS-координат (spoof или реальные)"),
        ("app_context",   "Bundle ID активного приложения для адаптации UI"),
        ("screenshot",    "JPEG-снимок экрана по запросу"),
        ("disconnect",    "Корректное завершение соединения"),
    ]
    
    let portItems = [
        ("9090", "TCP · Управляющий канал (JSON)"),
        ("9091", "UDP · Видеопоток (RTP-like)"),
        ("9092", "TCP · Аудиопоток (AAC/Opus)"),
        ("9093", "TCP · API Gateway (REST)"),
    ]
}

// MARK: - Security Section

struct SecuritySection: View {
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("БЕЗОПАСНОСТЬ")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(1.2)
                    Spacer()
                }
                
                ForEach(securityItems, id: \.0) { item in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(Color(hex: "34C759").opacity(0.15))
                                .frame(width: 34, height: 34)
                            Image(systemName: item.2)
                                .font(.system(size: 16))
                                .foregroundStyle(Color(hex: "34C759"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.0)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(item.1)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.5))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    Divider().background(.white.opacity(0.06))
                }
            }
        }
        
        GlassCard {
            VStack(spacing: 10) {
                HStack {
                    Text("© 2023–2026 FL-corp.ltd")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                }
                Text("DualSize Agent распространяется по лицензии MIT. Весь сетевой трафик остаётся в локальной сети. Серверы не задействованы.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
                    .lineSpacing(3)
            }
        }
    }
    
    let securityItems: [(String, String, String)] = [
        ("AES-256 шифрование",  "Все пакеты шифруются по AES-GCM с сессионным ключом",       "lock.fill"),
        ("Локальная сеть",       "Данные не покидают вашу Wi-Fi сеть или USB-канал",            "network"),
        ("Код сопряжения",       "Одноразовый 8-значный код истекает через 15 минут",          "key.fill"),
        ("Доверенные устройства","Список ПК, которым разрешён доступ без повторного ввода кода","checkmark.shield.fill"),
        ("Без аккаунта",         "Не требуется регистрация, облако или сторонние сервисы",     "person.slash.fill"),
    ]
}
