import Foundation
import UIKit

// MARK: - Battery Monitor

final class BatteryMonitor: ObservableObject {
    @Published var batteryLevel: Float = 1.0
    @Published var isCharging: Bool = false
    
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        update()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryChanged),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func batteryChanged() {
        DispatchQueue.main.async { self.update() }
    }
    
    private func update() {
        let level = UIDevice.current.batteryLevel
        batteryLevel = level < 0 ? 1.0 : level
        isCharging = [.charging, .full].contains(UIDevice.current.batteryState)
    }
}
