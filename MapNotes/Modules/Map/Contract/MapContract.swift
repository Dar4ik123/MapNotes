import Foundation
import CoreLocation

@MainActor
protocol MapViewInput: AnyObject {
    func configure(_ viewModel: MapViewModel)
    func moveCamera(to location: CLLocationCoordinate2D, zoom: Float)
    func showPlaces(_ places: [Place])
    func showError(_ message: String)
}

protocol MapViewOutput: AnyObject {
    func viewDidLoad()
    func didSelectPlace(_ place: Place)
    func didChangeVisibleRegion(_ bounds: GeoBounds)
    func didTapFilters()
    func didTapCenterOnUser()
    func didTapSearch()
    func didSelectSearchResult(_ place: Place)
}

@MainActor
protocol MapRouterInput: AnyObject {
    func showPlaceDetail(_ place: Place)
    func showCategoryFilter(
        selected: [OverpassCategory],
        delegate: CategoryFilterModuleOutput
    )
    func showPlaceSearch(
        bounds: GeoBounds,
        categories: [OverpassCategory],
        output: SearchBottomSheetOutput
    )
}
