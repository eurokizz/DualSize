import UIKit

// MARK: - Haptic Manager

final class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    private let impact = [
        UIImpactFeedbackGenerator.FeedbackStyle.light:   UIImpactFeedbackGenerator(style: .light),
        UIImpactFeedbackGenerator.FeedbackStyle.medium:  UIImpactFeedbackGenerator(style: .medium),
        UIImpactFeedbackGenerator.FeedbackStyle.heavy:   UIImpactFeedbackGenerator(style: .heavy),
        UIImpactFeedbackGenerator.FeedbackStyle.soft:    UIImpactFeedbackGenerator(style: .soft),
        UIImpactFeedbackGenerator.FeedbackStyle.rigid:   UIImpactFeedbackGenerator(style: .rigid),
    ]
    private let notification = UINotificationFeedbackGenerator()
    private let selection    = UISelectionFeedbackGenerator()
    
    private init() {
        impact.values.forEach { $0.prepare() }
        notification.prepare()
        selection.prepare()
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") != false else { return }
        impact[style]?.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") != false else { return }
        notification.notificationOccurred(type)
    }
    
    func selection() {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") != false else { return }
        selection.selectionChanged()
    }
}
