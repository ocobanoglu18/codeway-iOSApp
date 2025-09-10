import UIKit
import Foundation

enum AppearanceManager {
    private static let key = "appAppearance"
    
    static var current: AppAppearance {
        get { AppAppearance(rawValue: UserDefaults.standard.string(forKey: key) ?? "") ?? .system }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            apply(newValue)
        }
    }
    
    static func apply(_ appearance: AppAppearance = current) {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = appearance.interfaceStyle
            }
        }
    }
}
