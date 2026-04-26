import Foundation
import CoreLocation
import Alamofire

protocol PlacesService {
    func fetchPlaces(in bounds: GeoBounds, categories: [OverpassCategory]) async throws -> [Place]
    func searchPlacesByName(
        query: String,
        in bounds: GeoBounds,
        categories: [OverpassCategory]
    ) async throws -> [Place]
}

final class PlacesServiceImpl {
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
    }
}

extension PlacesServiceImpl: PlacesService {
    func fetchPlaces(in bounds: GeoBounds, categories: [OverpassCategory]) async throws -> [Place] {
        guard let url = URL(string: .overpassURL) else {
            throw ServiceError.invalidURL
        }

        let requestedCategories = categories.isEmpty ? [.tourism, .amenity, .historic] : categories
        let query = buildQuery(bounds: bounds, categories: requestedCategories)
        let parameters: [String: String] = [String.overpassDataParam: query]
        let headers: HTTPHeaders = [
            .headerContentType: .formContentType,
            .headerUserAgent: .userAgent
        ]

        let response = await session.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: headers
        )
        .validate()
        .serializingData(emptyResponseCodes: [])
        .response

        if let error = response.error {
            throw error
        }

        guard let data = response.data, !data.isEmpty else {
            throw ServiceError.emptyData
        }

        let decoded = try JSONDecoder().decode(OverpassResponse.self, from: data)
        return mapPlaces(from: decoded)
    }

    func searchPlacesByName(
        query: String,
        in bounds: GeoBounds,
        categories: [OverpassCategory]
    ) async throws -> [Place] {
        guard let url = URL(string: String.overpassURL) else {
            throw ServiceError.invalidURL
        }

        let requestedCategories = categories.isEmpty ? OverpassCategory.allCases : categories
        let expandedBounds = expandedBounds(for: bounds, scale: 1.7)
        let queryString = buildNameSearchQuery(
            query: query,
            bounds: expandedBounds,
            categories: requestedCategories
        )
        let parameters: [String: String] = [String.overpassDataParam: queryString]
        let headers: HTTPHeaders = [
            String.headerContentType: String.formContentType,
            String.headerUserAgent: String.userAgent
        ]

        let response = await session.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: headers
        )
        .validate()
        .serializingData(emptyResponseCodes: [])
        .response

        if let error = response.error {
            throw error
        }

        guard let data = response.data, !data.isEmpty else {
            throw ServiceError.emptyData
        }

        let decoded = try JSONDecoder().decode(OverpassResponse.self, from: data)
        return mapPlaces(from: decoded)
    }
}

private extension PlacesServiceImpl {
    func expandedBounds(for bounds: GeoBounds, scale: Double) -> GeoBounds {
        let centerLat = (bounds.north + bounds.south) / 2.0
        let centerLon = (bounds.east + bounds.west) / 2.0

        let halfLat = max(0.0001, (bounds.north - bounds.south) / 2.0) * scale
        let halfLon = max(0.0001, (bounds.east - bounds.west) / 2.0) * scale

        return GeoBounds(
            south: max(-90.0, centerLat - halfLat),
            west: max(-180.0, centerLon - halfLon),
            north: min(90.0, centerLat + halfLat),
            east: min(180.0, centerLon + halfLon)
        )
    }

    func buildQuery(bounds: GeoBounds, categories: [OverpassCategory]) -> String {
        let area = "\(bounds.south),\(bounds.west),\(bounds.north),\(bounds.east)"
        let clauses = categories.flatMap { category in
            [
                "  node[\"name\"][\"\(category.rawValue)\"](\(area));",
                "  way[\"name\"][\"\(category.rawValue)\"](\(area));",
                "  relation[\"name\"][\"\(category.rawValue)\"](\(area));"
            ]
        }.joined(separator: .newline)

        return """
        [out:json][timeout:5];
        (
        \(clauses)
        );
        out center 50;
        """
    }

    func escapedRegex(_ source: String) -> String {
        NSRegularExpression.escapedPattern(for: source)
    }

    func buildNameSearchQuery(
        query: String,
        bounds: GeoBounds,
        categories: [OverpassCategory]
    ) -> String {
        let area = "\(bounds.south),\(bounds.west),\(bounds.north),\(bounds.east)"
        let safeRegex = escapedRegex(query)
        let clauses = categories.flatMap { category in
            [
                "  node[\"name\"~\"\(safeRegex)\", i][\"\(category.rawValue)\"](\(area));",
                "  way[\"name\"~\"\(safeRegex)\", i][\"\(category.rawValue)\"](\(area));",
                "  relation[\"name\"~\"\(safeRegex)\", i][\"\(category.rawValue)\"](\(area));"
            ]
        }.joined(separator: String.newline)

        return """
        [out:json][timeout:5];
        (
        \(clauses)
        );
        out center 50;
        """
    }

    func subtitle(from tags: Tags?) -> String? {
        guard let tags else { return nil }
        var parts: [String] = []
        if let amenity = tags.amenity, amenity != .unknown { parts.append(amenity.rawValue.replacingOccurrences(of: "_", with: " ")) }
        if let tourism = tags.tourism, tourism != .unknown { parts.append(tourism.rawValue.replacingOccurrences(of: "_", with: " ")) }
        if let historic = tags.historic, historic != .unknown { parts.append(historic.rawValue.replacingOccurrences(of: "_", with: " ")) }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    func primaryMapCategory(from tags: Tags?) -> OverpassCategory {
        guard let tags else { return .amenity }
        if let tourism = tags.tourism, tourism != .unknown { return .tourism }
        if let historic = tags.historic, historic != .unknown { return .historic }
        if let amenity = tags.amenity, amenity != .unknown { return .amenity }
        if let leisure = tags.leisure, leisure != .unknown { return .leisure }
        if let shop = tags.shop, shop != .unknown { return .shop }
        if let office = tags.office, office != .unknown { return .office }
        if let craft = tags.craft, craft != .unknown { return .craft }
        if let emergency = tags.emergency, emergency != .unknown { return .emergency }
        if let military = tags.military, military != .unknown { return .military }
        return .amenity
    }

    func address(from tags: Tags?) -> String? {
        guard let tags else { return nil }
        var segments: [String] = []
        if let street = tags.addrStreet {
            var line = street
            if let num = tags.addrHousenumber { line += ", \(num)" }
            segments.append(line)
        }
        if let city = tags.addrCity { segments.append(city) }
        if let post = tags.addrPostcode { segments.append(post) }
        return segments.isEmpty ? nil : segments.joined(separator: ", ")
    }

    func mapPlaces(from response: OverpassResponse) -> [Place] {
        var seenIDs = Set<String>()
        return response.elements.compactMap { item -> Place? in
            guard let title = (item.localizedName ?? item.displayName), !title.isEmpty else { return nil }
            guard let point = item.point else { return nil }

            let placeID = "\(item.type.rawValue)-\(item.id)"
            guard seenIDs.insert(placeID).inserted else { return nil }

            let tags = item.tags
            return Place(
                id: placeID,
                title: title,
                latitude: point.lat,
                longitude: point.lon,
                subtitle: subtitle(from: tags),
                address: address(from: tags),
                phone: tags?.phone,
                website: tags?.website,
                openingHours: tags?.openingHours,
                placeDescription: tags?.description,
                wikipedia: tags?.wikipedia,
                mapCategory: primaryMapCategory(from: tags)
            )
        }
    }

    enum ServiceError: LocalizedError {
        case invalidURL
        case emptyData

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return .invalidPlacesURL
            case .emptyData:
                return .emptyAPIData
            }
        }
    }
}

extension GeoBounds {
    static func around(_ coordinate: CLLocationCoordinate2D, delta: Double = 0.08) -> GeoBounds {
        GeoBounds(
            south: coordinate.latitude - delta,
            west: coordinate.longitude - delta,
            north: coordinate.latitude + delta,
            east: coordinate.longitude + delta
        )
    }
}

private extension String {
    static let overpassURL = "https://overpass-api.de/api/interpreter"
    static let overpassDataParam = "data"
    static let headerContentType = "Content-Type"
    static let headerUserAgent = "User-Agent"
    static let formContentType = "application/x-www-form-urlencoded; charset=utf-8"
    static let userAgent = "MapNotes/1.0 (iOS)"
    static let invalidPlacesURL = "Некорректный URL запроса мест."
    static let emptyAPIData = "API вернул пустой ответ."
    static let newline = "\n"
}
