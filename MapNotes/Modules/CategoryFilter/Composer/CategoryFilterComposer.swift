import UIKit

struct CategoryFilterInputContainer {
    let selected: [OverpassCategory]
    let output: CategoryFilterModuleOutput
}

enum CategoryFilterComposer {
    static func make(input: CategoryFilterInputContainer) -> UIViewController {
        let router = CategoryFilterRouter()

        let presenter = CategoryFilterPresenter(
            router: router,
            flowModel: CategoryFilterFlowModel(selectedCategories: Set(input.selected)),
            adapter: CategoryFilterAdapterImpl(),
            output: input.output
        )

        let viewController = CategoryFilterViewController(presenter: presenter)
        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
