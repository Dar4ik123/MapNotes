import Foundation

struct CategoryFilterFlowModel {
    var selectedCategories: Set<OverpassCategory> = []
    let allCategories: [OverpassCategory] = OverpassCategory.allCases
}
