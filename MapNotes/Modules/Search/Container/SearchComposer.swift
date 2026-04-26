import UIKit

struct SearchInputContainer {
    let output: SearchBottomSheetOutput
    let placesService: PlacesService
    let bounds: GeoBounds
    let categories: [OverpassCategory]
}

enum SearchComposer {
    static func make(input: SearchInputContainer) -> UIViewController {
        let presenter = SearchPresenter(
            placesService: input.placesService,
            bounds: input.bounds,
            categories: input.categories,
            flowModel: SearchFlowModel(),
            adapter: SearchAdapterImpl()
        )
        presenter.output = input.output

        let viewController = SearchBottomSheetViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
