import UIKit

struct MapInputContainer {
    let locationService: LocationService
    let placesService: PlacesService
    let flowModel: MapFlowModel
    let viewModelAdapter: MapAdapter
}

enum MapComposer {
    static func make(input: MapInputContainer) -> UIViewController {
        let moduleFactory = ModuleFactoryImpl(placesService: input.placesService)
        let router = MapRouter(moduleFactory: moduleFactory)
        let presenter = MapPresenter(
            router: router,
            locationService: input.locationService,
            placesService: input.placesService,
            flowModel: input.flowModel,
            adapter: input.viewModelAdapter
        )
        let viewController = MapViewController(presenter: presenter)

        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}
