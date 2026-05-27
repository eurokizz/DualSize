import Foundation
import CoreMotion

// MARK: - Motion Tracker

final class MotionTracker: ObservableObject {
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var yaw: Double = 0
    @Published var isActive: Bool = false
    
    private let manager = CMMotionManager()
    weak var connectionManager: ConnectionManager?
    
    func start(sending cm: ConnectionManager) {
        guard manager.isDeviceMotionAvailable else { return }
        self.connectionManager = cm
        isActive = true
        
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            self?.pitch = motion.attitude.pitch
            self?.roll  = motion.attitude.roll
            self?.yaw   = motion.attitude.yaw
            
            cm.sendJSON([
                "type": "gyro",
                "pitch": motion.attitude.pitch,
                "roll":  motion.attitude.roll,
                "yaw":   motion.attitude.yaw,
                "gx": motion.rotationRate.x,
                "gy": motion.rotationRate.y,
                "gz": motion.rotationRate.z
            ])
        }
    }
    
    func stop() {
        manager.stopDeviceMotionUpdates()
        isActive = false
    }
}
