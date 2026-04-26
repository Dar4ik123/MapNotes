import Foundation

protocol PlaceDetailAdapter {
    func makeViewModel(place: Place) -> PlaceDetailViewModel
}

final class PlaceDetailAdapterImpl: PlaceDetailAdapter {
    func makeViewModel(place: Place) -> PlaceDetailViewModel {
        var cells: [PlaceDetailCellType] = []

        if let subtitle = place.subtitle, !subtitle.isEmpty {
            cells.append(.info(title: .categoryTitle, value: subtitle))
        }
        let coords = String(format: .coordinatesFormat, place.latitude, place.longitude)
        cells.append(.info(title: .coordinatesTitle, value: coords))
        if let address = place.address, !address.isEmpty {
            cells.append(.info(title: .addressTitle, value: address))
        }
        if let phone = place.phone, !phone.isEmpty {
            cells.append(.info(title: .phoneTitle, value: phone))
        }
        if let opening = place.openingHours, !opening.isEmpty {
            cells.append(.info(title: .hoursTitle, value: opening))
        }
        if let wikipedia = place.wikipedia, !wikipedia.isEmpty {
            cells.append(.info(title: .wikipediaTitle, value: wikipedia))
        }
        if let description = place.placeDescription, !description.isEmpty {
            cells.append(.description(description))
        }
        if let website = place.website?.trimmingCharacters(in: .whitespacesAndNewlines), !website.isEmpty {
            cells.append(.websiteButton(website))
        }

        return PlaceDetailViewModel(title: place.title, cells: cells)
    }
}

private extension String {
    static let categoryTitle = "Категория"
    static let coordinatesTitle = "Координаты"
    static let addressTitle = "Адрес"
    static let phoneTitle = "Телефон"
    static let hoursTitle = "Часы"
    static let wikipediaTitle = "Wikipedia"
    static let coordinatesFormat = "%.5f, %.5f"
}
