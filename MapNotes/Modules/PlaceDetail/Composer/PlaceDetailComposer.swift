import UIKit

struct PlaceDetailInputContainer {
    let place: Place
    let flowModel: PlaceDetailFlowModel
}

enum PlaceDetailComposer {
    static func make(input: PlaceDetailInputContainer) -> UIViewController {
        let router = PlaceDetailRouter()
        let presenter = PlaceDetailPresenter(
            router: router,
            flowModel: input.flowModel,
            adapter: PlaceDetailAdapterImpl()
        )
        let viewController = PlaceDetailViewController(presenter: presenter)

        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}
