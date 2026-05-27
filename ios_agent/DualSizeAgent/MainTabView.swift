import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var selectedTab = 0
    @State private var tabBarVisible = true
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                StatusView()
                    .tag(0)

                StreamView()
                    .tag(1)

                SettingsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom iOS 26-style Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Custom Tab Bar (iOS 26 Liquid Glass style)

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var connectionManager: ConnectionManager
    
    let tabs: [TabItem] = [
        TabItem(icon: "dot.radiowaves.left.and.right", label: "Статус", activeIcon: "dot.radiowaves.left.and.right"),
        TabItem(icon: "play.rectangle", label: "Стрим", activeIcon: "play.rectangle.fill"),
        TabItem(icon: "gearshape", label: "Настройки", activeIcon: "gearshape.fill")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                TabBarButton(
                    tab: tab,
                    index: index,
                    isSelected: selectedTab == index,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = index
                        }
                        HapticManager.shared.impact(style: .light)
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            // iOS 26 floating glass tab bar
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.25),
                                .white.opacity(0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 10)
        .shadow(color: Color(hex: "007AFF").opacity(connectionManager.isConnected ? 0.15 : 0), radius: 30, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

struct TabItem {
    let icon: String
    let label: String
    let activeIcon: String
}

struct TabBarButton: View {
    let tab: TabItem
    let index: Int
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "007AFF"), Color(hex: "5AC8FA")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 32)
                            .shadow(color: Color(hex: "007AFF").opacity(0.4), radius: 8, x: 0, y: 4)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                        .frame(width: 44, height: 32)
                }
                
                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color(hex: "007AFF") : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3)) {
                        isPressed = false
                    }
                }
        )
    }
}
