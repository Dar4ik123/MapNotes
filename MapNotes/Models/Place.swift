import Foundation

struct Place: Hashable {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double

    let subtitle: String?
    let address: String?
    let phone: String?
    let website: String?
    let openingHours: String?
    let placeDescription: String?
    let wikipedia: String?
    let mapCategory: OverpassCategory
}
