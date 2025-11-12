
import SwiftUI
import Toolbox

#if canImport(UIKit)
import UIKit

// https://gist.github.com/Hiroki-Kawakami/231115bd3c2f739781f53ecea39e2c1f
public class StatusBarConfigurator: ObservableObject {
    public static let shared = StatusBarConfigurator()
    private var window: UIWindow?
    
    @Published var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// Whether or not the status bar should be hidden.
    @Published var hideStatusBar: Bool = false {
        didSet {
            window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// Whether or not the home indicator should be hidden.
    @Published var hideHomeIndicator: Bool = false {
        didSet {
            window?.rootViewController?.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }
    
    /// The current color scheme.
    @Published var colorScheme: ColorScheme? = nil
    
    /// The fallback status bar style.
    public var fallbackStyle: UIStatusBarStyle = .default
    
    fileprivate func prepare(scene: UIWindowScene) {
        guard !UIDevice.model.hasHomeButton else {
            return
        }
        
        if window == nil {
            let window = UIWindow(windowScene: scene)
            let viewController = ViewController()
            viewController.configurator = self
            window.rootViewController = viewController
            window.frame = UIScreen.main.bounds
            window.alpha = 0
            self.window = window
        }
        
        window?.windowLevel = .statusBar
        window?.makeKeyAndVisible()
    }
    
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        guard let colorScheme, style == .default else {
            self.statusBarStyle = style
            return
        }
        
        // Use the default status bar style for the chosen color scheme
        switch colorScheme {
        case .light:
            self.statusBarStyle = .darkContent
        case .dark:
            self.statusBarStyle = .lightContent
        @unknown default:
            self.statusBarStyle = style
        }
    }
    
    func setPreferredColorScheme(_ colorScheme: ColorScheme?) {
        if let colorScheme = colorScheme {
            if colorScheme == .dark {
                self.statusBarStyle = .lightContent
                self.fallbackStyle = .lightContent
            }
            else {
                self.statusBarStyle = .darkContent
                self.fallbackStyle = .darkContent
            }
        }
        else {
            self.statusBarStyle = .default
            self.fallbackStyle = .default
        }
    }
    
    fileprivate class ViewController: UIViewController {
        weak var configurator: StatusBarConfigurator!
        override var preferredStatusBarStyle: UIStatusBarStyle { configurator.statusBarStyle }
        override var prefersHomeIndicatorAutoHidden: Bool { configurator.hideHomeIndicator }
        override var prefersStatusBarHidden: Bool { configurator.hideStatusBar }
    }
}

fileprivate struct SceneFinder: UIViewRepresentable {
    var getScene: ((UIWindowScene) -> ())?
    
    func makeUIView(context: Context) -> View { View() }
    func updateUIView(_ uiView: View, context: Context) { uiView.getScene = getScene }
    
    class View: UIView {
        var getScene: ((UIWindowScene) -> ())?
        override func didMoveToWindow() {
            if let scene = window?.windowScene {
                getScene?(scene)
            }
        }
    }
}

extension View {
    public func prepareStatusBarConfigurator(preferredColorScheme: ColorScheme? = nil, statusBarHidden: Bool = false) -> some View {
        let configurator = StatusBarConfigurator.shared
        return self.background(SceneFinder { scene in
            configurator.prepare(scene: scene)
            
            DispatchQueue.main.async {
                configurator.setPreferredColorScheme(preferredColorScheme)
                
                if statusBarHidden {
                    configurator.hideStatusBar = true
                }
            }
        })
    }
}

extension View {
    /// Sets the status bar style color for this view.
    public func statusBarStyle(_ style: UIStatusBarStyle) -> some View {
        return self.onAppear {
            UIApplication.pushStatusBarStyle(style)
        }
        .onDisappear {
            UIApplication.popStatusBarStyle()
        }
    }
}

extension UIApplication {
    static var statusBarStyleHierarchy: [UIStatusBarStyle] = []
    
    private static func setStatusBarStyle(_ style: UIStatusBarStyle) {
        StatusBarConfigurator.shared.setStatusBarStyle(style)
    }
    
    public static func pushStatusBarStyle(_ style: UIStatusBarStyle) {
        guard !UIDevice.model.hasHomeButton else {
            return
        }
        
        Self.statusBarStyleHierarchy.append(style)
        Self.setStatusBarStyle(style)
    }
    
    public static func popStatusBarStyle() {
        guard !UIDevice.model.hasHomeButton else {
            return
        }
        
        _ = Self.statusBarStyleHierarchy.popLast()
        
        if let style = Self.statusBarStyleHierarchy.last {
            Self.setStatusBarStyle(style)
        }
        else {
            Self.setStatusBarStyle(StatusBarConfigurator.shared.fallbackStyle)
        }
    }
}

#endif
