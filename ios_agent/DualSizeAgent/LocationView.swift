import SwiftUI
import CoreLocation
import MapKit

struct LocationView: View {
    @StateObject private var locationService = LocationSpoofService()
    @State private var appeared = false
    @State private var showRouteBuilder = false
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    let presets: [LocationPreset] = [
        LocationPreset(name: "Москва", emoji: "🇷🇺", lat: 55.7558, lng: 37.6173),
        LocationPreset(name: "Сан-Франциско", emoji: "🇺🇸", lat: 37.7749, lng: -122.4194),
        LocationPreset(name: "Токио", emoji: "🇯🇵", lat: 35.6762, lng: 139.6503),
        LocationPreset(name: "Лондон", emoji: "🇬🇧", lat: 51.5074, lng: -0.1278),
        LocationPreset(name: "Нью-Йорк", emoji: "🇺🇸", lat: 40.7128, lng: -74.0060),
        LocationPreset(name: "Дубай", emoji: "🇦🇪", lat: 25.2048, lng: 55.2708),
        LocationPreset(name: "Куперт.", emoji: "🍎", lat: 37.3382, lng: -121.8863),
        LocationPreset(name: "Берлин", emoji: "🇩🇪", lat: 52.5200, lng: 13.4050),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Active location card
                        ActiveLocationCard(locationService: locationService)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 30)
                        
                        // Map mini-view
                        GlassCard {
                            VStack(spacing: 12) {
                                HStack {
                                    Label("Карта", systemImage: "map.fill")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                    Spacer()
                                    if locationService.isSpoofing {
                                        HStack(spacing: 5) {
                                            Circle().fill(Color(hex: "FF3B30")).frame(width: 6, height: 6)
                                            Text("SPOOF")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(Color(hex: "FF3B30"))
                                        }
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(Color(hex: "FF3B30").opacity(0.15))
                                        .clipShape(Capsule())
                                    }
                                }
                                
                                Map(position: $cameraPosition) {
                                    if let pin = locationService.spoofedLocation {
                                        Marker("Spoof", systemImage: "location.fill", coordinate: pin)
                                            .tint(Color(hex: "FF3B30"))
                                    }
                                }
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .onTapGesture { location in }
                                
                                Text("Нажмите на карту для выбора точки")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.spring(response: 0.6).delay(0.1), value: appeared)
                        
                        // Preset locations
                        GlassCard {
                            VStack(spacing: 14) {
                                HStack {
                                    Label("Быстрые локации", systemImage: "star.fill")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(presets) { preset in
                                        Button {
                                            HapticManager.shared.impact(style: .medium)
                                            locationService.setLocation(lat: preset.lat, lng: preset.lng)
                                            withAnimation {
                                                cameraPosition = .region(MKCoordinateRegion(
                                                    center: CLLocationCoordinate2D(latitude: preset.lat, longitude: preset.lng),
                                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                                ))
                                            }
                                        } label: {
                                            VStack(spacing: 4) {
                                                Text(preset.emoji)
                                                    .font(.system(size: 22))
                                                Text(preset.name)
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundStyle(.white.opacity(0.7))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.7)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(.white.opacity(0.07))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.spring(response: 0.6).delay(0.15), value: appeared)
                        
                        // Route Simulator
                        RouteSimulatorCard(locationService: locationService)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 30)
                            .animation(.spring(response: 0.6).delay(0.2), value: appeared)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Геолокация")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }
}

struct LocationPreset: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let lat: Double
    let lng: Double
}

// MARK: - Active Location Card

struct ActiveLocationCard: View {
    @ObservedObject var locationService: LocationSpoofService
    @State private var latText = ""
    @State private var lngText = ""
    @State private var showManualInput = false
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Текущая локация")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        if locationService.isSpoofing, let loc = locationService.spoofedLocation {
                            Text(String(format: "%.4f, %.4f", loc.latitude, loc.longitude))
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: "FF3B30"))
                        } else {
                            Text("Реальная позиция")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color(hex: "34C759"))
                        }
                    }
                    Spacer()
                    
                    Image(systemName: locationService.isSpoofing ? "location.slash.fill" : "location.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(locationService.isSpoofing ? Color(hex: "FF3B30") : Color(hex: "34C759"))
                }
                
                if locationService.isSpoofing {
                    Button {
                        HapticManager.shared.notification(type: .success)
                        locationService.stopSpoofing()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Вернуть реальную позицию")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(hex: "34C759").opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .strokeBorder(Color(hex: "34C759").opacity(0.4), lineWidth: 1)
                        )
                        .foregroundStyle(Color(hex: "34C759"))
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                
                // Manual input
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showManualInput.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "pencil.and.list.clipboard")
                        Text("Ввести координаты вручную")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Image(systemName: showManualInput ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
                
                if showManualInput {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            TextField("Широта (55.7558)", text: $latText)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                            TextField("Долгота (37.6173)", text: $lngText)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        
                        Button {
                            guard let lat = Double(latText.replacingOccurrences(of: ",", with: ".")),
                                  let lng = Double(lngText.replacingOccurrences(of: ",", with: ".")) else { return }
                            HapticManager.shared.impact(style: .medium)
                            locationService.setLocation(lat: lat, lng: lng)
                        } label: {
                            Text("Применить")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    LinearGradient(colors: [Color(hex: "FF3B30"), Color(hex: "FF6B6B")], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - Route Simulator Card

struct RouteSimulatorCard: View {
    @ObservedObject var locationService: LocationSpoofService
    
    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Label("Симуляция маршрута", systemImage: "figure.walk.motion")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    
                    if locationService.isSimulatingRoute {
                        Text("Активна")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: "34C759"))
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color(hex: "34C759").opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                
                // Speed control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Скорость")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(locationService.routeSpeed)) км/ч")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "007AFF"))
                    }
                    Slider(value: $locationService.routeSpeed, in: 1...200, step: 1)
                        .tint(Color(hex: "007AFF"))
                }
                
                // Preset routes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пресеты маршрутов")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(RoutePreset.allPresets) { route in
                            Button {
                                HapticManager.shared.impact(style: .medium)
                                locationService.startRouteSimulation(route: route)
                            } label: {
                                HStack {
                                    Image(systemName: route.icon)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color(hex: "007AFF"))
                                    Text(route.name)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.8))
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                if locationService.isSimulatingRoute {
                    Button {
                        HapticManager.shared.notification(type: .warning)
                        locationService.stopRouteSimulation()
                    } label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Остановить маршрут")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(hex: "FF3B30").opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .strokeBorder(Color(hex: "FF3B30").opacity(0.4), lineWidth: 1)
                        )
                        .foregroundStyle(Color(hex: "FF3B30"))
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct RoutePreset: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let points: [(Double, Double)]
    
    static let allPresets: [RoutePreset] = [
        RoutePreset(name: "Прогулка", icon: "figure.walk", points: [(55.7558, 37.6173), (55.7568, 37.6200), (55.7580, 37.6220)]),
        RoutePreset(name: "Поездка", icon: "car.fill", points: [(55.7558, 37.6173), (55.7700, 37.6400), (55.7900, 37.6600)]),
        RoutePreset(name: "Пробежка", icon: "figure.run", points: [(55.7558, 37.6173), (55.7570, 37.6150), (55.7590, 37.6130)]),
        RoutePreset(name: "Велосипед", icon: "bicycle", points: [(55.7558, 37.6173), (55.7620, 37.6300), (55.7680, 37.6450)]),
    ]
}

// MARK: - Location Spoof Service

class LocationSpoofService: ObservableObject {
    @Published var isSpoofing = false
    @Published var isSimulatingRoute = false
    @Published var spoofedLocation: CLLocationCoordinate2D?
    @Published var routeSpeed: Double = 60
    
    private var routeTimer: Timer?
    private var routePoints: [(Double, Double)] = []
    private var currentPointIndex = 0
    
    func setLocation(lat: Double, lng: Double) {
        spoofedLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        isSpoofing = true
        // Отправляем через ConnectionManager
        NotificationCenter.default.post(
            name: .locationSpoofChanged,
            object: nil,
            userInfo: ["lat": lat, "lng": lng]
        )
    }
    
    func stopSpoofing() {
        isSpoofing = false
        spoofedLocation = nil
        stopRouteSimulation()
        NotificationCenter.default.post(name: .locationSpoofStopped, object: nil)
    }
    
    func startRouteSimulation(route: RoutePreset) {
        routePoints = route.points
        currentPointIndex = 0
        isSimulatingRoute = true
        
        let interval = 1.0 / (routeSpeed / 3.6) * 10
        routeTimer?.invalidate()
        routeTimer = Timer.scheduledTimer(withTimeInterval: max(0.5, interval), repeats: true) { [weak self] _ in
            guard let self = self, !self.routePoints.isEmpty else { return }
            let point = self.routePoints[self.currentPointIndex % self.routePoints.count]
            self.setLocation(lat: point.0, lng: point.1)
            self.currentPointIndex += 1
        }
    }
    
    func stopRouteSimulation() {
        routeTimer?.invalidate()
        routeTimer = nil
        isSimulatingRoute = false
    }
}

extension Notification.Name {
    static let locationSpoofChanged = Notification.Name("locationSpoofChanged")
    static let locationSpoofStopped = Notification.Name("locationSpoofStopped")
}
