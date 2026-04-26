import UIKit

final class CategoryFilterRouter {
    weak var viewController: UIViewController?
}

extension CategoryFilterRouter: CategoryFilterRouterInput {
    func close() {
        viewController?.dismiss(animated: true)
    }
}
