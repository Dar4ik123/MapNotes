import Foundation

protocol MapAdapter {
    func makeViewModel(selectedCategories: [OverpassCategory]) -> MapViewModel
}

final class MapAdapterImpl: MapAdapter {
    func makeViewModel(selectedCategories: [OverpassCategory]) -> MapViewModel {
        if selectedCategories.isEmpty {
            return MapViewModel(searchPlaceholder: .mapSearchPlaceholder)
        }
        let titles = selectedCategories.map(\.russianTitle).joined(separator: String.categoriesSeparator)
        return MapViewModel(searchPlaceholder: "\(String.searchPrefix)\(titles)")
    }
}

private extension String {
    static let mapSearchPlaceholder = "Поиск места"
    static let categoriesSeparator = ", "
    static let searchPrefix = "Поиск: "
}
