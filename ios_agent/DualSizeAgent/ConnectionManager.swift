import Foundation
import Network
import Combine
import UIKit

// MARK: - Connection Manager

final class ConnectionManager: ObservableObject {
    
    enum ConnectionState {
        case disconnected, connecting, pairing, connected
    }
    
    enum ConnectionType {
        case usb, wifi
    }
    
    // MARK: Published State
    @Published var connectionState: ConnectionState = .disconnected
    @Published var connectionType: ConnectionType = .wifi
    @Published var connectedDeviceName: String? = nil
    @Published var connectedDeviceModel: String? = nil
    @Published var trustedDevices: [String] = []
    @Published var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "onboardingDone")
    
    var isConnected: Bool { connectionState == .connected }
    
    // MARK: Private
    private var browser: NWBrowser?
    private var connection: NWConnection?
    private var listener: NWListener?
    private var heartbeatTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTrustedDevices()
        if UserDefaults.standard.bool(forKey: "autoConnect") {
            startDiscovery()
        }
        
        $hasCompletedOnboarding
            .dropFirst()
            .sink { val in
                UserDefaults.standard.set(val, forKey: "onboardingDone")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Discovery
    
    func startDiscovery() {
        guard connectionState == .disconnected else { return }
        connectionState = .connecting
        
        // Try USB tunnel first (port 9090)
        tryUSBConnection()
        
        // Simultaneously browse Bonjour
        let parameters = NWParameters.tcp
        browser = NWBrowser(for: .bonjour(type: "_dualsize._tcp", domain: nil), using: parameters)
        
        browser?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .failed:
                    self?.connectionState = .disconnected
                default:
                    break
                }
            }
        }
        
        browser?.browseResultsChangedHandler = { [weak self] results, _ in
            guard let first = results.first else { return }
            self?.connectToEndpoint(first.endpoint)
        }
        
        browser?.start(queue: .global(qos: .userInitiated))
    }
    
    func disconnect() {
        heartbeatTimer?.invalidate()
        connection?.cancel()
        connection = nil
        browser?.cancel()
        browser = nil
        
        DispatchQueue.main.async {
            self.connectionState = .disconnected
            self.connectedDeviceName = nil
            self.connectedDeviceModel = nil
        }
    }
    
    func resetAllSettings() {
        disconnect()
        trustedDevices.removeAll()
        UserDefaults.standard.removeObject(forKey: "trustedDevices")
        UserDefaults.standard.removeObject(forKey: "autoConnect")
        UserDefaults.standard.removeObject(forKey: "onboardingDone")
        hasCompletedOnboarding = false
    }
    
    // MARK: - Private Helpers
    
    private func tryUSBConnection() {
        let endpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: 9090)
        connectToEndpoint(endpoint)
    }
    
    private func connectToEndpoint(_ endpoint: NWEndpoint) {
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        
        connection = NWConnection(to: endpoint, using: params)
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.handleConnected()
                case .failed, .cancelled:
                    self?.connectionState = .disconnected
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: .global(qos: .userInitiated))
        receive()
    }
    
    private func handleConnected() {
        connectionState = .connected
        connectedDeviceName = "DualSize Desktop"
        connectedDeviceModel = "Windows 11"
        connectionType = .wifi
        sendHandshake()
        startHeartbeat()
    }
    
    private func sendHandshake() {
        let info = DeviceIdentifier.shared
        let payload: [String: Any] = [
            "type": "handshake",
            "hw": info.hwMachine,
            "model": info.modelName,
            "screen_w": info.screenPoints.width,
            "screen_h": info.screenPoints.height,
            "scale": info.scale,
            "corner_radius": info.cornerRadius,
            "display_feature": info.displayFeature.rawValue,
            "dynamic_island_width": info.dynamicIslandWidth,
            "ios_version": UIDevice.current.systemVersion,
            "app_version": "1.0.0"
        ]
        sendJSON(payload)
    }
    
    private func startHeartbeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.sendJSON(["type": "ping", "ts": Date().timeIntervalSince1970])
        }
    }
    
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.handleIncomingData(data)
            }
            if !isComplete {
                self?.receive()
            }
        }
    }
    
    private func handleIncomingData(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return }
        
        switch type {
        case "pong":
            break
        case "disconnect":
            DispatchQueue.main.async { self.disconnect() }
        case "device_info":
            if let name = json["name"] as? String {
                DispatchQueue.main.async {
                    self.connectedDeviceName = name
                    self.connectedDeviceModel = json["os"] as? String
                }
            }
        default:
            break
        }
    }
    
    func sendJSON(_ payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
        var framed = Data()
        var length = UInt32(data.count).bigEndian
        framed.append(Data(bytes: &length, count: 4))
        framed.append(data)
        connection?.send(content: framed, completion: .idempotent)
    }
    
    private func loadTrustedDevices() {
        trustedDevices = UserDefaults.standard.stringArray(forKey: "trustedDevices") ?? []
    }
    
    func addTrustedDevice(_ name: String) {
        if !trustedDevices.contains(name) {
            trustedDevices.append(name)
            UserDefaults.standard.set(trustedDevices, forKey: "trustedDevices")
        }
    }
}
