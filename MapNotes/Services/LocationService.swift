import Foundation
import CoreLocation

protocol LocationServiceOutput: AnyObject {
    func locationServiceDidResolve(_ coordinate: CLLocationCoordinate2D)
    func locationServiceDidFail(_ error: Error)
}

final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private weak var output: LocationServiceOutput?
}

extension LocationService {
    func requestCurrentLocation(output: LocationServiceOutput) {
        self.output = output
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            output.locationServiceDidFail(LocationError.permissionDenied)
        default:
            output.locationServiceDidFail(LocationError.unknown)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            failCurrentRequest(with: LocationError.permissionDenied)
        case .notDetermined:
            break
        default:
            failCurrentRequest(with: LocationError.unknown)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else {
            failCurrentRequest(with: LocationError.noLocation)
            return
        }

        output?.locationServiceDidResolve(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        failCurrentRequest(with: error)
    }
    
    private func failCurrentRequest(with error: Error) {
        output?.locationServiceDidFail(error)
    }
}

extension LocationService {
    enum LocationError: LocalizedError {
        case permissionDenied
        case noLocation
        case unknown

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return String.locationPermissionDenied
            case .noLocation:
                return String.locationNotFound
            case .unknown:
                return String.locationUnknownError
            }
        }
    }
}

private extension String {
    static let locationPermissionDenied = "Доступ к геолокации запрещен."
    static let locationNotFound = "Не удалось определить текущую геопозицию."
    static let locationUnknownError = "Неизвестная ошибка геолокации."
}
