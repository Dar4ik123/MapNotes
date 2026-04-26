import Foundation

struct OverpassResponse: Decodable {
    let elements: [Element]

    private enum CodingKeys: String, CodingKey {
        case elements
    }
}

extension OverpassResponse {
    struct Element: Decodable {
        let type: ElementType
        let id: Int64
        let lat: Double?
        let lon: Double?
        let center: Coordinate?
        let geometry: [Coordinate]?
        let tags: Tags?

        private enum CodingKeys: String, CodingKey {
            case type, id, lat, lon, center, geometry, tags
        }
    }

    enum ElementType: String, Decodable {
        case node
        case way
        case relation
    }

    struct Coordinate: Decodable {
        let lat: Double
        let lon: Double

        private enum CodingKeys: String, CodingKey {
            case lat, lon
        }
    }
}

extension OverpassResponse.Element {
    var point: OverpassResponse.Coordinate? {
        if let lat, let lon {
            return .init(lat: lat, lon: lon)
        }
        if let center {
            return center
        }
        return geometry?.first
    }

    var displayName: String? {
        tags?.name
    }

    var localizedName: String? {
        tags?.nameRu ?? tags?.nameEn ?? tags?.name
    }
}

struct Tags: Decodable {
    let name: String?
    let nameEn: String?
    let nameRu: String?

    let amenity: Amenity?
    let shop: Shop?
    let tourism: Tourism?
    let historic: Historic?
    let leisure: Leisure?
    let office: Office?
    let craft: Craft?
    let emergency: Emergency?
    let military: Military?

    let openingHours: String?
    let phone: String?
    let website: String?

    let addrCity: String?
    let addrStreet: String?
    let addrHousenumber: String?
    let addrPostcode: String?

    let description: String?
    let wikipedia: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case nameEn = "name:en"
        case nameRu = "name:ru"
        case amenity, shop, tourism, historic, leisure, office, craft, emergency, military
        case openingHours = "opening_hours"
        case phone, website
        case addrCity = "addr:city"
        case addrStreet = "addr:street"
        case addrHousenumber = "addr:housenumber"
        case addrPostcode = "addr:postcode"
        case description, wikipedia
    }
}

enum Amenity: String, Decodable {
    case restaurant, cafe, fastFood = "fast_food", pub, bar, iceCream = "ice_cream"
    case foodCourt = "food_court", bakery, barbecue, biergarten

    case fuel, parking, bicycleParking = "bicycle_parking", carSharing = "car_sharing"
    case chargingStation = "charging_station", carWash = "car_wash"

    case bank, atm, pharmacy, hospital, clinic, doctors, dentist, veterinary
    case school, kindergarten, library, theatre, cinema, nightclub, casino
    case postOffice = "post_office", police, fireStation = "fire_station"
    case townhall, courthouse, prison

    case toilets, bench, shelter, fountain, drinkingWater = "drinking_water"
    case recycling, wasteBasket = "waste_basket", wasteDisposal = "waste_disposal"

    case placeOfWorship = "place_of_worship", monastery, graveYard = "grave_yard"
    case socialFacility = "social_facility", childcare

    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Amenity(rawValue: string) ?? .unknown
    }
}

enum Shop: String, Decodable {
    case convenience, supermarket, bakery, butcher, greengrocer, alcohol
    case clothes, shoes, jewelry, electronics, furniture, hardware
    case bookstore, stationery, music, video, games, toys
    case beauty, hairdresser, cosmetics, perfumery, chemist
    case carRepair = "car_repair", carParts = "car_parts", bicycle
    case florist, gift, tobacco, newsagent, lottery, mobilePhone = "mobile_phone"
    case computer, copyshop, optician, hearingAids = "hearing_aids"
    case sports, outdoor, gardenCentre = "garden_centre", pet, petGrooming = "pet_grooming"
    case art, antiques, collector, charity, varietyStore = "variety_store"
    case mall, departmentStore = "department_store", wholesale
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Shop(rawValue: string) ?? .unknown
    }
}

enum Tourism: String, Decodable {
    case hotel, motel, hostel, guestHouse = "guest_house", apartment
    case chalet, campSite = "camp_site", caravanSite = "caravan_site"
    case museum, gallery, attraction, viewpoint, picnicSite = "picnic_site"
    case information, themePark = "theme_park", zoo, aquarium
    case alpineHut = "alpine_hut", wildernessHut = "wilderness_hut"
    case artwork, yes
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Tourism(rawValue: string) ?? .unknown
    }
}

enum Historic: String, Decodable {
    case castle, fort, ruins, archaeologicalSite = "archaeological_site"
    case memorial, monument, statue, waysideCross = "wayside_cross"
    case waysideShrine = "wayside_shrine", battlefield, wreck
    case cityGate = "city_gate", tower, church, monastery
    case manor, farm, house, building, district, quarter
    case mine, ship, locomotive, aircraft, vehicle
    case yes, unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Historic(rawValue: string) ?? .unknown
    }
}

enum Leisure: String, Decodable {
    case park, garden, natureReserve = "nature_reserve", playground
    case sportsCentre = "sports_centre", fitnessCentre = "fitness_centre"
    case fitnessStation = "fitness_station", swimmingPool = "swimming_pool"
    case waterPark = "water_park", miniatureGolf = "miniature_golf"
    case golfCourse = "golf_course", stadium, track, pitch
    case marina, slipway, dogPark = "dog_park", common, beachResort = "beach_resort"
    case birdHide = "bird_hide", fishing, sauna, dance, hackerspace
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Leisure(rawValue: string) ?? .unknown
    }
}

enum Office: String, Decodable {
    case accountant, architect, association, charity, company
    case educationalInstitution = "educational_institution", employmentAgency = "employment_agency"
    case engineer, government, insurance, it, lawyer, newspaper
    case ngo, politicalParty = "political_party", religion, research
    case telecommunication, travelAgent = "travel_agent", yes
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Office(rawValue: string) ?? .unknown
    }
}

enum Craft: String, Decodable {
    case bakery, brewery, carpentry, electrician, gardener, glaziery
    case hvac, jeweler, locksmith, painter, photographer, plasterer
    case plumber, roofer, shoemaker, tailor, tiler, winery
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Craft(rawValue: string) ?? .unknown
    }
}

enum Emergency: String, Decodable {
    case ambulanceStation = "ambulance_station", fireStation = "fire_station"
    case police, hospital, defibrillator, phone, accessPoint = "access_point"
    case assemblyPoint = "assembly_point", lifeguard, mountainRescue = "mountain_rescue"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Emergency(rawValue: string) ?? .unknown
    }
}

enum Military: String, Decodable {
    case airfield, barracks, bunker, checkpoint, navalBase = "naval_base"
    case nuclear, obstacle, range, yes
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Military(rawValue: string) ?? .unknown
    }
}
