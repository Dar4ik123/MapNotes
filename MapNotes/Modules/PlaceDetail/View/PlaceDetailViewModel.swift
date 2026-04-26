import Foundation

struct PlaceDetailViewModel {
    let title: String
    let cells: [PlaceDetailCellType]
}

enum PlaceDetailCellType {
    case info(title: String, value: String)
    case description(String)
    case websiteButton(String)
}
