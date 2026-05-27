import UIKit

// MARK: - Haptic Manager

final class HapticManager: ObservableObject {
    static let shared = HapticManager()

    private let impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [
        .light:  UIImpactFeedbackGenerator(style: .light),
        .medium: UIImpactFeedbackGenerator(style: .medium),
        .heavy:  UIImpactFeedbackGenerator(style: .heavy),
        .soft:   UIImpactFeedbackGenerator(style: .soft),
        .rigid:  UIImpactFeedbackGenerator(style: .rigid),
    ]
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator    = UISelectionFeedbackGenerator()

    private init() {
        impactGenerators.values.forEach { $0.prepare() }
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") != false else { return }
        impactGenerators[style]?.impactOccurred()
    }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") != false else { return }
        notificationGenerator.notificationOccurred(type)
    }

    func selection() {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") != false else { return }
        selectionGenerator.selectionChanged()
    }
}
