import UIKit

class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selection.prepare()
        notification.prepare()
    }

    func tap() {
        lightImpact.impactOccurred()
    }

    func select() {
        selection.selectionChanged()
    }

    func bondFormed() {
        heavyImpact.impactOccurred(intensity: 0.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mediumImpact.impactOccurred(intensity: 0.5)
        }
    }

    func aminoAcidAdded() {
        mediumImpact.impactOccurred()
    }

    func success() {
        notification.notificationOccurred(.success)
    }

    func error() {
        notification.notificationOccurred(.error)
    }
}
