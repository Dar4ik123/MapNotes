import Foundation

@MainActor
protocol PlaceDetailViewInput: AnyObject {
    func configure(_ viewModel: PlaceDetailViewModel)
}

protocol PlaceDetailViewOutput: AnyObject {
    func viewDidLoad()
    func didTapOpenWebsite()
    func didSelectCell()
}

@MainActor
protocol PlaceDetailRouterInput: AnyObject {
    func openWebsite(url: URL)
}
