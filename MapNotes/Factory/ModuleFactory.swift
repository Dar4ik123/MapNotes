import UIKit

@MainActor
protocol ModuleFactory {
    func makePlaceDetail(place: Place) -> UIViewController
    func makeCategoryFilter(
        selected: [OverpassCategory],
        output: CategoryFilterModuleOutput
    ) -> UIViewController
    func makeSearch(
        bounds: GeoBounds,
        categories: [OverpassCategory],
        output: SearchBottomSheetOutput
    ) -> UIViewController
}

final class ModuleFactoryImpl: ModuleFactory {
    private let placesService: PlacesService

    init(placesService: PlacesService) {
        self.placesService = placesService
    }

    func makePlaceDetail(place: Place) -> UIViewController {
        let input = PlaceDetailInputContainer(
            place: place,
            flowModel: PlaceDetailFlowModel(place: place)
        )
        return PlaceDetailComposer.make(input: input)
    }

    func makeCategoryFilter(
        selected: [OverpassCategory],
        output: CategoryFilterModuleOutput
    ) -> UIViewController {
        let input = CategoryFilterInputContainer(
            selected: selected,
            output: output
        )
        return CategoryFilterComposer.make(input: input)
    }

    func makeSearch(
        bounds: GeoBounds,
        categories: [OverpassCategory],
        output: SearchBottomSheetOutput
    ) -> UIViewController {
        let input = SearchInputContainer(
            output: output,
            placesService: placesService,
            bounds: bounds,
            categories: categories
        )
        return SearchComposer.make(input: input)
    }
}
