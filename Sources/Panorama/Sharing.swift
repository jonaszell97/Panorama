
#if canImport(UIKit)

import UIKit

fileprivate func getRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return nil
    }
    
    return windowScene.windows.first?.rootViewController
}

/// Display the system share sheet with the selected items.
///
/// - Parameters:
///   - itemsToShare: The items to share.
///   - sourceRect: The optional rectangle to display the sheet in.
public func showShareSheet(itemsToShare: [Any], sourceRect: CGRect? = nil) {
    guard let rootController = getRootViewController() else {
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
