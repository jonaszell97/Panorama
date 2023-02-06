
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// A result of opening a URL.
public enum OpenURLActionResult {
    case handled
    case discarded
    case systemAction(_ url: URL? = nil)
}

@available(iOS 15, macOS 12, *)
fileprivate extension OpenURLActionResult {
    var result: OpenURLAction.Result {
        switch self {
        case .handled: return .handled
        case .discarded: return .discarded
        case .systemAction(let url):
            if let url = url {
                return .systemAction(url)
            }
            
            return .systemAction
        }
    }
}

public extension View {
    /// Install the URL opening callback if available.
    func openURL(_ action: @escaping (URL) -> OpenURLActionResult) -> some View {
        ZStack {
            if #available(iOS 15, macOS 12, *) {
                self.environment(\.openURL, OpenURLAction { url in
                    action(url).result
                })
            }
            else {
                self
            }
        }
    }
}

// MARK: Share sheet

#if canImport(UIKit)

/// Display the system share sheet with the given items.
/// 
/// - Parameters:
///   - itemsToShare: The items to share.
///   - sourceRect: The dimensions of the share sheet rect, or `nil` if they should be determined automatically.
public func displayShareSheet(itemsToShare: [Any], sourceRect: CGRect? = nil) {
    guard let rootController = UIApplication.shared.windows.first?.rootViewController else {
        return
    }
    
    let activityViewController = UIActivityViewController(activityItems: itemsToShare,
                                                          applicationActivities: nil)
    
    activityViewController.popoverPresentationController?.sourceView = rootController.view
    activityViewController.popoverPresentationController?.sourceRect = sourceRect ??
        .init(x: UIScreen.main.bounds.width*0.5, y: UIScreen.main.bounds.height*0.5, width: 0, height: 0)
    
    rootController.present(activityViewController, animated: true, completion: nil)
}

#endif
