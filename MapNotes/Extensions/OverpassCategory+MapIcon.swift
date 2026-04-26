import UIKit

extension OverpassCategory {
    var sfSymbolName: String {
        switch self {
        case .tourism: return "binoculars.fill"
        case .amenity: return "fork.knife.circle.fill"
        case .historic: return "building.columns.fill"
        case .leisure: return "tree.fill"
        case .shop: return "bag.fill"
        case .office: return "briefcase.fill"
        case .craft: return "hammer.fill"
        case .emergency: return "cross.case.fill"
        case .military: return "shield.lefthalf.filled"
        }
    }

    var mapPinTintColor: UIColor {
        switch self {
        case .tourism: return .systemTeal
        case .amenity: return .systemOrange
        case .historic: return .systemBrown
        case .leisure: return .systemGreen
        case .shop: return .systemPink
        case .office: return .systemBlue
        case .craft: return .systemGray
        case .emergency: return .systemRed
        case .military: return .label
        }
    }

    func mapPinImage(pointSize: CGFloat = 28) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        let symbolName = sfSymbolName
        let base = UIImage(systemName: symbolName, withConfiguration: config)
            ?? UIImage(systemName: "mappin.circle.fill", withConfiguration: config)
        return (base ?? UIImage()).withTintColor(mapPinTintColor, renderingMode: .alwaysOriginal)
    }
}
