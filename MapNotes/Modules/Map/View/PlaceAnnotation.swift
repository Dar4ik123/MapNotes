import Foundation
import CoreLocation
import MapKit

final class PlaceAnnotation: NSObject, MKAnnotation {
    let place: Place
    var coordinate: CLLocationCoordinate2D
    var title: String? { place.title }
    var subtitle: String? { place.subtitle }

    init(place: Place) {
        self.place = place
        self.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        super.init()
    }
}
