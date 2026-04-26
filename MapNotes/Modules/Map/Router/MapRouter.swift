import UIKit

@MainActor
final class MapRouter {
    weak var viewController: UIViewController?
    private let moduleFactory: ModuleFactory
    
    init(moduleFactory: ModuleFactory) {
        self.moduleFactory = moduleFactory
    }
}

extension MapRouter: MapRouterInput {
    func showPlaceDetail(_ place: Place) {
        let detail = moduleFactory.makePlaceDetail(place: place)
        viewController?.navigationController?.pushViewController(detail, animated: true)
    }

    func showCategoryFilter(
        selected: [OverpassCategory],
        delegate: CategoryFilterModuleOutput
    ) {
        let controller = moduleFactory.makeCategoryFilter(selected: selected, output: delegate)
        controller.modalPresentationStyle = .pageSheet
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(controller, animated: true)
    }

    func showPlaceSearch(
        bounds: GeoBounds,
        categories: [OverpassCategory],
        output: SearchBottomSheetOutput
    ) {
        let controller = moduleFactory.makeSearch(
            bounds: bounds,
            categories: categories,
            output: output
        )
        controller.modalPresentationStyle = .pageSheet
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(controller, animated: true)
    }
}
