import Foundation

struct SearchViewModel {
    let rows: [Row]
    let isLoading: Bool
    
    struct Row {
        let title: String
        let subtitle: String
        let iconSystemName: String
    }
}
