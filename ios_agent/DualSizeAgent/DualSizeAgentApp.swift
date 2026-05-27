import SwiftUI

@main
struct DualSizeAgentApp: App {
    
    @StateObject private var connectionManager = ConnectionManager()
    @StateObject private var streamingManager = StreamingManager()
    @StateObject private var motionTracker = MotionTracker()
    @StateObject private var batteryMonitor = BatteryMonitor()
    @StateObject private var hapticManager = HapticManager()
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectionManager)
                .environmentObject(streamingManager)
                .environmentObject(motionTracker)
                .environmentObject(batteryMonitor)
                .environmentObject(hapticManager)
                .preferredColorScheme(.dark)
        }
    }
    
    private func configureAppearance() {
        // Прозрачные navigation bars в стиле iOS 26
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        
        // Tab bar прозрачный
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
