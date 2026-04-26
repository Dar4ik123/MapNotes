import UIKit

struct CategoryFilterRowViewModel {
    let title: String
    let iconSystemName: String
    let tint: UIColor
    let isSelected: Bool
}

struct CategoryFilterViewModel {
    let title: String
    let applyButtonTitle: String
    let rows: [CategoryFilterRowViewModel]
}
