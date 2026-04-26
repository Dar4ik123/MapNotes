import Foundation
import CoreLocation

@MainActor
final class MapPresenter: MapViewOutput {
    weak var view: MapViewInput?

    private let router: MapRouterInput
    private let locationService: LocationService
    private let placesService: PlacesService
    private let adapter: MapAdapter

    private var flowModel: MapFlowModel
    private var pendingRegionTask: Task<Void, Never>?

    init(
        router: MapRouterInput,
        locationService: LocationService,
        placesService: PlacesService,
        flowModel: MapFlowModel,
        adapter: MapAdapter
    ) {
        self.router = router
        self.locationService = locationService
        self.placesService = placesService
        self.flowModel = flowModel
        self.adapter = adapter
    }

    func viewDidLoad() {
        updatePresentation()
        flowModel.locationRequestContext = .initialLoad
        locationService.requestCurrentLocation(output: self)
    }

    func didSelectPlace(_ place: Place) {
        router.showPlaceDetail(place)
    }

    func didChangeVisibleRegion(_ bounds: GeoBounds) {
        flowModel.currentVisibleBounds = bounds
        guard flowModel.hasCompletedInitialPlacesLoad else { return }

        pendingRegionTask?.cancel()
        pendingRegionTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: flowModel.regionFetchDebounceNanos)
            guard !Task.isCancelled else { return }

            if let last = flowModel.lastFetchedBounds,
               boundsAreSimilar(last, bounds) {
                return
            }
            await loadPlaces(in: bounds)
        }
    }

    func didTapFilters() {
        router.showCategoryFilter(selected: flowModel.selectedCategories, delegate: self)
    }

    func didTapCenterOnUser() {
        flowModel.locationRequestContext = .centerOnUser
        locationService.requestCurrentLocation(output: self)
    }

    func didTapSearch() {
        guard let bounds = flowModel.currentVisibleBounds ?? flowModel.lastFetchedBounds else { return }
        router.showPlaceSearch(
            bounds: bounds,
            categories: flowModel.selectedCategories,
            output: self
        )
    }

    func didSelectSearchResult(_ place: Place) {
        view?.moveCamera(to: .init(latitude: place.latitude, longitude: place.longitude), zoom: .zoomValue)
    }

    private func loadPlaces(near coordinate: CLLocationCoordinate2D) {
        view?.moveCamera(to: coordinate, zoom: .zoomValue)
        let bounds = GeoBounds.around(coordinate)
        flowModel.currentVisibleBounds = bounds
        Task { [weak self] in
            await self?.loadPlaces(in: bounds)
        }
    }

    private func loadPlaces(in bounds: GeoBounds) async {
        flowModel.fetchGeneration += 1
        let generation = flowModel.fetchGeneration

        do {
            let places = try await placesService.fetchPlaces(in: bounds, categories: flowModel.selectedCategories)
            guard generation == flowModel.fetchGeneration else { return }
            flowModel.lastFetchedBounds = bounds
            view?.showPlaces(places)
        } catch {
            guard generation == flowModel.fetchGeneration else { return }
            view?.showError(error.localizedDescription)
        }

        flowModel.hasCompletedInitialPlacesLoad = true
    }

    private func updatePresentation() {
        view?.configure(adapter.makeViewModel(selectedCategories: flowModel.selectedCategories))
    }
}

extension MapPresenter: CategoryFilterModuleOutput {
    func categoryFilterViewController(didApply categories: [OverpassCategory]) {
        flowModel.selectedCategories = categories.isEmpty ? flowModel.defaultCategories : categories
        updatePresentation()
        guard let bounds = flowModel.currentVisibleBounds ?? flowModel.lastFetchedBounds else { return }
        Task { [weak self] in
            await self?.loadPlaces(in: bounds)
        }
    }
}

extension MapPresenter: SearchBottomSheetOutput {
    func searchBottomSheetPresenter(didSelect place: Place) {
        didSelectSearchResult(place)
    }
}

extension MapPresenter: LocationServiceOutput {
    func locationServiceDidResolve(_ coordinate: CLLocationCoordinate2D) {
        guard let context = flowModel.locationRequestContext else { return }
        flowModel.locationRequestContext = nil
        switch context {
        case .initialLoad:
            loadPlaces(near: coordinate)
        case .centerOnUser:
            view?.moveCamera(to: coordinate, zoom: .zoomValue)
        }
    }

    func locationServiceDidFail(_ error: Error) {
        guard let context = flowModel.locationRequestContext else { return }
        flowModel.locationRequestContext = nil
        switch context {
        case .initialLoad:
            view?.showError(error.localizedDescription)
            loadPlaces(near: flowModel.fallbackCoordinate)
        case .centerOnUser:
            view?.showError(error.localizedDescription)
        }
    }
}

private extension MapPresenter {
    func boundsAreSimilar(_ lhs: GeoBounds, _ rhs: GeoBounds, tolerance: Double = 0.002) -> Bool {
        abs(lhs.south - rhs.south) < tolerance &&
        abs(lhs.west - rhs.west) < tolerance &&
        abs(lhs.north - rhs.north) < tolerance &&
        abs(lhs.east - rhs.east) < tolerance
    }
}

private extension Float {
    static let zoomValue: Float = 13
}
