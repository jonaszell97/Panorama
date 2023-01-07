
import SwiftUI

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
