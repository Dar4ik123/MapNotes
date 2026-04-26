import Foundation

protocol CategoryFilterModuleOutput: AnyObject {
    func categoryFilterViewController(didApply categories: [OverpassCategory])
}

protocol CategoryFilterViewInput: AnyObject {
    func configure(_ viewModel: CategoryFilterViewModel)
}

@MainActor
protocol CategoryFilterViewOutput: AnyObject {
    func viewDidLoad()
    func didToggleCategory(at index: Int)
    func didTapApply()
}

@MainActor
protocol CategoryFilterRouterInput: AnyObject {
    func close()
}
