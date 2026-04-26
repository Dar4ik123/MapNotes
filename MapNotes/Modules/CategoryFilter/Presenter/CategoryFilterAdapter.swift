import UIKit

protocol CategoryFilterAdapter {
    func makeViewModel(flowModel: CategoryFilterFlowModel) -> CategoryFilterViewModel
}

final class CategoryFilterAdapterImpl: CategoryFilterAdapter {
    func makeViewModel(flowModel: CategoryFilterFlowModel) -> CategoryFilterViewModel {
        let rows = flowModel.allCategories.map { category in
            CategoryFilterRowViewModel(
                title: category.russianTitle,
                iconSystemName: category.sfSymbolName,
                tint: category.mapPinTintColor,
                isSelected: flowModel.selectedCategories.contains(category)
            )
        }

        return CategoryFilterViewModel(
            title: .filterScreenTitle,
            applyButtonTitle: .applyButtonTitle,
            rows: rows
        )
    }
}

private extension String {
    static let filterScreenTitle = "Категории"
    static let applyButtonTitle = "Применить"
}
