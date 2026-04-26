import Foundation

struct SearchFlowModel {
    var query: String
    var results: [Place]
    var isLoading: Bool
    var fetchGeneration: Int

    init(
        query: String = .empty,
        results: [Place] = [],
        isLoading: Bool = false,
        fetchGeneration: Int = 0
    ) {
        self.query = query
        self.results = results
        self.isLoading = isLoading
        self.fetchGeneration = fetchGeneration
    }
}
