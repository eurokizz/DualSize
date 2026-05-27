import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var showOnboarding = true
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            if showOnboarding && !connectionManager.hasCompletedOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            } else {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showOnboarding)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Onboarding

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var currentPage = 0
    @State private var animateLogo = false
    @State private var animateText = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "iphone.and.arrow.forward",
            title: "Добро пожаловать\nв DualSize",
            subtitle: "Зеркалирование вашего iPhone на компьютер в реальном времени с нулевой задержкой",
            gradient: [Color(hex: "007AFF"), Color(hex: "5AC8FA")]
        ),
        OnboardingPage(
            icon: "wifi",
            title: "USB и Wi-Fi",
            subtitle: "Подключайтесь через кабель для минимальной задержки или по сети — где удобно",
            gradient: [Color(hex: "34C759"), Color(hex: "30D158")]
        ),
        OnboardingPage(
            icon: "gamecontroller.fill",
            title: "Полное управление",
            subtitle: "Управляйте телефоном с компьютера: тапы, свайпы, жесты и клавиатура",
            gradient: [Color(hex: "AF52DE"), Color(hex: "BF5AF2")]
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Безопасное подключение",
            subtitle: "Шифрование AES-256. Только ваши устройства — никаких серверов",
            gradient: [Color(hex: "FF9500"), Color(hex: "FF6B00")]
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            VStack(spacing: 0) {
                // Logo area
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .blue.opacity(0.5), radius: 30, x: 0, y: 10)
                        
                        Image(systemName: "rectangle.on.rectangle")
                            .font(.system(size: 50, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(hex: "5AC8FA")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateLogo ? 1.0 : 0.5)
                            .opacity(animateLogo ? 1.0 : 0)
                    }
                    .scaleEffect(animateLogo ? 1.0 : 0.8)
                    .opacity(animateLogo ? 1.0 : 0)
                    
                    Text("DualSize")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "5AC8FA")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(animateText ? 1.0 : 0)
                        .offset(y: animateText ? 0 : 20)
                }
                .padding(.top, 80)
                
                Spacer()
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 280)
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color(hex: "007AFF") : .white.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // CTA Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        connectionManager.hasCompletedOnboarding = true
                        showOnboarding = false
                    }
                } label: {
                    HStack {
                        Text(currentPage < pages.count - 1 ? "Далее" : "Начать")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: pages[currentPage].gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: pages[currentPage].gradient.first?.opacity(0.5) ?? .clear, radius: 20, x: 0, y: 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Skip button
                if currentPage < pages.count - 1 {
                    Button("Пропустить") {
                        connectionManager.hasCompletedOnboarding = true
                        showOnboarding = false
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 40)
                } else {
                    Spacer().frame(height: 56)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateLogo = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                animateText = true
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 88, height: 88)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    )
                
                Image(systemName: page.icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            
            Text(page.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            
            Text(page.subtitle)
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.65))
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}
