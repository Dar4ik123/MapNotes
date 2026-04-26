import Foundation

protocol SearchAdapter {
    func makeViewModel(results: [Place], isLoading: Bool) -> SearchViewModel
}

final class SearchAdapterImpl: SearchAdapter {
    func makeViewModel(results: [Place], isLoading: Bool) -> SearchViewModel {
        let rows = results.map { place in
            SearchViewModel.Row(
                title: place.title,
                subtitle: place.subtitle ?? String(format: String.coordinatesFormat, place.latitude, place.longitude),
                iconSystemName: place.mapCategory.sfSymbolName
            )
        }
        return SearchViewModel(rows: rows, isLoading: isLoading)
    }
}

private extension String {
    static let coordinatesFormat = "%.5f, %.5f"
}
