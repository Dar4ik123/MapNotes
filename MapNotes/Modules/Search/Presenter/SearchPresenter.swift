import Foundation

@MainActor
final class SearchPresenter {
    private let placesService: PlacesService
    private let bounds: GeoBounds
    private let categories: [OverpassCategory]
    private let adapter: SearchAdapter
    
    private var flowModel: SearchFlowModel
    private var pendingSearchTask: Task<Void, Never>?
    
    weak var view: SearchBottomSheetViewInput?
    weak var output: SearchBottomSheetOutput?
    
    init(
        placesService: PlacesService,
        bounds: GeoBounds,
        categories: [OverpassCategory],
        flowModel: SearchFlowModel,
        adapter: SearchAdapter
    ) {
        self.placesService = placesService
        self.bounds = bounds
        self.categories = categories
        self.flowModel = flowModel
        self.adapter = adapter
    }
}

extension SearchPresenter: SearchBottomSheetViewOutput {
    func queryDidChange(_ query: String) {
        pendingSearchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        flowModel.query = trimmed
        guard !trimmed.isEmpty else {
            flowModel.results = []
            updatePresentation()
            return
        }
        
        pendingSearchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await search(query: trimmed)
        }
    }
    
    func didSelectResult(at index: Int) {
        guard flowModel.results.indices.contains(index) else { return }
        output?.searchBottomSheetPresenter(didSelect: flowModel.results[index])
    }
}

private extension SearchPresenter {
    func search(query: String) async {
        flowModel.fetchGeneration += 1
        let generation = flowModel.fetchGeneration
        flowModel.isLoading = true
        updatePresentation()

        do {
            let places = try await placesService.searchPlacesByName(
                query: query,
                in: bounds,
                categories: categories
            )
            guard generation == flowModel.fetchGeneration else { return }
            flowModel.isLoading = false
            flowModel.results = places
            updatePresentation()
        } catch {
            guard generation == flowModel.fetchGeneration else { return }
            flowModel.isLoading = false
            updatePresentation()
            view?.showError(error.localizedDescription)
        }
    }
    
    func updatePresentation() {
        let viewModel = adapter.makeViewModel(
            results: flowModel.results,
            isLoading: flowModel.isLoading
        )
        view?.configure(viewModel)
    }
}
