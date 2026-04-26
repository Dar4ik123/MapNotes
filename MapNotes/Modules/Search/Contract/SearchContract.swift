import Foundation

@MainActor
protocol SearchBottomSheetOutput: AnyObject {
    func searchBottomSheetPresenter(didSelect place: Place)
}

@MainActor
protocol SearchBottomSheetViewInput: AnyObject {
    func configure(_ viewModel: SearchViewModel)
    func showError(_ message: String)
}

protocol SearchBottomSheetViewOutput: AnyObject {
    func queryDidChange(_ query: String)
    func didSelectResult(at index: Int)
}
