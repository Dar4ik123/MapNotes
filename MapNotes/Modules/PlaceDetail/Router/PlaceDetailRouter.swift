import UIKit
import SafariServices

final class PlaceDetailRouter {
    weak var viewController: UIViewController?
}

extension PlaceDetailRouter: PlaceDetailRouterInput {
    func openWebsite(url: URL) {
        let safari = SFSafariViewController(url: url)
        viewController?.present(safari, animated: true)
    }
}
