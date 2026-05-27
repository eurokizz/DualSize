import Foundation
import Combine

// MARK: - Pairing Service

final class PairingService: ObservableObject {
    
    enum PairingState {
        case idle, generating, waitingForConfirmation, paired, failed(String)
    }
    
    @Published var state: PairingState = .idle
    @Published var currentCode: String = ""
    @Published var expiresAt: Date = Date()
    @Published var pendingDeviceName: String? = nil
    
    private var renewTimer: Timer?
    
    // MARK: - Generate Code
    
    func generateCode() {
        state = .generating
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        currentCode = String((0..<8).map { _ in chars.randomElement()! })
        expiresAt = Date().addingTimeInterval(900)
        state = .waitingForConfirmation
        
        scheduleRenewal()
    }
    
    // MARK: - Validate incoming code
    
    func validate(_ input: String) -> Bool {
        let normalized = input.uppercased().replacingOccurrences(of: "-", with: "")
        return normalized == currentCode && Date() < expiresAt
    }
    
    // MARK: - Confirm pairing
    
    func confirm(deviceName: String) {
        pendingDeviceName = deviceName
        state = .paired
        renewTimer?.invalidate()
    }
    
    func reject() {
        state = .failed("Запрос отклонён")
        generateCode()
    }
    
    private func scheduleRenewal() {
        renewTimer?.invalidate()
        let remaining = expiresAt.timeIntervalSinceNow
        renewTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
            self?.generateCode()
        }
    }
    
    // MARK: - TOTP-like code display format
    
    var formattedCode: String {
        guard currentCode.count == 8 else { return currentCode }
        return "\(currentCode.prefix(4))-\(currentCode.suffix(4))"
    }
    
    var secondsRemaining: Int {
        max(0, Int(expiresAt.timeIntervalSinceNow))
    }
}
