import Foundation

final class PlaceDetailPresenter: PlaceDetailViewOutput {
    weak var view: PlaceDetailViewInput?

    private let router: PlaceDetailRouterInput
    private let adapter: PlaceDetailAdapter
    private var flowModel: PlaceDetailFlowModel

    init(
        router: PlaceDetailRouterInput,
        flowModel: PlaceDetailFlowModel,
        adapter: PlaceDetailAdapter
    ) {
        self.router = router
        self.flowModel = flowModel
        self.adapter = adapter
    }

    func viewDidLoad() {
        let viewModel = adapter.makeViewModel(place: flowModel.place)
        view?.configure(viewModel)
    }

    func didTapOpenWebsite() {
        guard let url = normalizedWebsiteURL(from: flowModel.place.website) else { return }
        router.openWebsite(url: url)
    }

    func didSelectCell() {
        guard let url = normalizedWebsiteURL(from: flowModel.place.website) else { return }
        router.openWebsite(url: url)
    }
}

private extension PlaceDetailPresenter {
    func normalizedWebsiteURL(from string: String?) -> URL? {
        guard var value = string?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        if !value.lowercased().hasPrefix("http://") && !value.lowercased().hasPrefix("https://") {
            value = "https://\(value)"
        }
        return URL(string: value)
    }
}
