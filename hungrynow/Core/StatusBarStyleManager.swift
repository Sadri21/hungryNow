//
//  StatusBarStyleManager.swift
//  hungrynow
//
//  Bridges status bar appearance management from SwiftUI to the hosting UIViewController.
//  Enables runtime control over `preferredStatusBarStyle` with smooth animated transitions.
//

import Combine
import SwiftUI
import UIKit

/// Manages the application status bar style dynamically at runtime.
/// Bridges between SwiftUI and UIKit's `preferredStatusBarStyle`.
public final class StatusBarStyleManager: ObservableObject {
    public static let shared = StatusBarStyleManager()

    /// The active custom status bar style. When nil, UIKit's default system behavior is preserved.
    @Published public private(set) var currentStyle: UIStatusBarStyle? = nil

    private static var swizzledClasses = Set<ObjectIdentifier>()

    private init() {}

    /// Sets the status bar style to match the screen's background color scheme:
    /// dark text in Light mode (over light cream #F7F1EF),
    /// light text in Dark mode (over dark wine #241016).
    public func setStyle(for colorScheme: ColorScheme) {
        setStyle(colorScheme == .dark ? .lightContent : .darkContent)
    }

    /// Sets the status bar style with a smooth animated transition.
    /// - Parameter style: The target `UIStatusBarStyle`, or `nil` to restore default system behavior.
    public func setStyle(_ style: UIStatusBarStyle?) {
        currentStyle = style

        let applyUpdate = { [weak self] in
            guard let self = self else { return }
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            for scene in scenes {
                for window in scene.windows {
                    if let rootVC = window.rootViewController {
                        self.swizzleHostingControllerIfNeeded(rootVC)
                        UIView.animate(withDuration: 0.2) {
                            rootVC.setNeedsStatusBarAppearanceUpdate()
                        }
                    }
                }
            }
        }

        if Thread.isMainThread {
            applyUpdate()
        } else {
            DispatchQueue.main.async(execute: applyUpdate)
        }
    }

    /// UIHostingController overrides `preferredStatusBarStyle` and `childForStatusBarStyle`.
    /// Swizzling UIViewController directly does not work because UIHostingController's vtable
    /// overrides those methods. We must replace the implementation on the concrete hosting class.
    private func swizzleHostingControllerIfNeeded(_ rootVC: UIViewController) {
        let targetClass: AnyClass = type(of: rootVC)
        let classId = ObjectIdentifier(targetClass)
        guard !Self.swizzledClasses.contains(classId) else { return }
        Self.swizzledClasses.insert(classId)

        let statusSelector = #selector(getter: UIViewController.preferredStatusBarStyle)
        if let method = class_getInstanceMethod(targetClass, statusSelector) {
            let block: @convention(block) (AnyObject) -> UIStatusBarStyle = { receiver in
                if let custom = StatusBarStyleManager.shared.currentStyle {
                    return custom
                }
                // When nil, automatically match system interface style:
                // Dark text (.darkContent) in Light Mode, White text (.lightContent) in Dark Mode.
                if let vc = receiver as? UIViewController, vc.traitCollection.userInterfaceStyle == .dark {
                    return .lightContent
                } else {
                    return .darkContent
                }
            }

            method_setImplementation(method, imp_implementationWithBlock(block))
        }

        let childSelector = #selector(getter: UIViewController.childForStatusBarStyle)
        if let childMethod = class_getInstanceMethod(targetClass, childSelector) {
            let childBlock: @convention(block) (AnyObject) -> UIViewController? = { _ in
                return nil // Root hosting controller handles status bar style directly
            }

            method_setImplementation(childMethod, imp_implementationWithBlock(childBlock))
        }
    }
}
