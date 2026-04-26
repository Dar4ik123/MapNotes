import Foundation

final class CategoryFilterPresenter {
    private let router: CategoryFilterRouterInput
    private let adapter: CategoryFilterAdapter
    private var flowModel: CategoryFilterFlowModel
    
    weak var view: CategoryFilterViewInput?
    weak var output: CategoryFilterModuleOutput?
    
    init(
        router: CategoryFilterRouterInput,
        flowModel: CategoryFilterFlowModel,
        adapter: CategoryFilterAdapter,
        output: CategoryFilterModuleOutput
    ) {
        self.router = router
        self.flowModel = flowModel
        self.adapter = adapter
        self.output = output
    }
}

extension CategoryFilterPresenter: CategoryFilterViewOutput {
    func viewDidLoad() {
        updatePresentation()
    }

    func didToggleCategory(at index: Int) {
        guard flowModel.allCategories.indices.contains(index) else { return }
        let category = flowModel.allCategories[index]
        if flowModel.selectedCategories.contains(category) {
            flowModel.selectedCategories.remove(category)
        } else {
            flowModel.selectedCategories.insert(category)
        }
        updatePresentation()
    }

    func didTapApply() {
        let categories = flowModel.allCategories.filter { flowModel.selectedCategories.contains($0) }
        output?.categoryFilterViewController(didApply: categories)
        router.close()
    }

    private func updatePresentation() {
        view?.configure(adapter.makeViewModel(flowModel: flowModel))
    }
}
