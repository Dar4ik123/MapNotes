import Foundation
import CoreLocation

struct MapFlowModel {
    var selectedCategories: [OverpassCategory] = [.tourism, .amenity, .historic]
    var lastFetchedBounds: GeoBounds?
    var currentVisibleBounds: GeoBounds?
    var hasCompletedInitialPlacesLoad = false
    var fetchGeneration = 0
    let fallbackCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.753709, longitude: 37.619813)
    let defaultCategories: [OverpassCategory] = [.tourism, .amenity, .historic]
    let regionFetchDebounceNanos: UInt64 = 1_000_000_000
    var locationRequestContext: LocationRequestContext? = .initialLoad
}

enum LocationRequestContext {
    case initialLoad
    case centerOnUser
}
