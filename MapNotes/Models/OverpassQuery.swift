import Foundation

struct GeoBounds {
    let south: Double
    let west: Double
    let north: Double
    let east: Double
}

enum OverpassCategory: String, CaseIterable {
    case tourism
    case amenity
    case historic
    case leisure
    case shop
    case office
    case craft
    case emergency
    case military
}

extension OverpassCategory {
    var russianTitle: String {
        switch self {
        case .tourism: return "Туризм"
        case .amenity: return "Услуги"
        case .historic: return "Историческое место"
        case .leisure: return "Досуг"
        case .shop: return "Магазин"
        case .office: return "Офис"
        case .craft: return "Ремесло"
        case .emergency: return "Экстренные службы"
        case .military: return "Военное"
        }
    }
}

