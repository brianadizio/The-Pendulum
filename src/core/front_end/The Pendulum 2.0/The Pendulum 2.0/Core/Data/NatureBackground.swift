// NatureBackground.swift
// The Pendulum 2.0
// Nature photo background model and catalog for the play screen

import Foundation

// MARK: - Nature Location

enum NatureLocation: String, CaseIterable, Identifiable {
    case sachuest = "Sachuest Point"
    case acadia = "Acadia"
    case joshuaTree = "Joshua Tree"
    case guatemala = "Guatemala"
    case newEngland = "New England"

    var id: String { rawValue }

    var photoCount: Int {
        switch self {
        case .sachuest: return 8
        case .acadia: return 3
        case .joshuaTree: return 4
        case .guatemala: return 2
        case .newEngland: return 1
        }
    }

    /// Asset name prefix for this location
    var assetPrefix: String {
        switch self {
        case .sachuest: return "bg_sachuest"
        case .acadia: return "bg_acadia"
        case .joshuaTree: return "bg_joshua_tree"
        case .guatemala: return "bg_guatemala"
        case .newEngland: return "bg_new_england"
        }
    }
}

// MARK: - Nature Photo

struct NaturePhoto: Identifiable, Equatable {
    let id: String           // Asset catalog name, e.g. "bg_sachuest_1"
    let location: NatureLocation
    let index: Int           // 1-based index within location

    var displayName: String {
        "\(location.rawValue) \(index)"
    }
}

// MARK: - Nature Background Manager

class NatureBackgroundManager {
    static let shared = NatureBackgroundManager()

    /// All available nature photo backgrounds
    let allPhotos: [NaturePhoto]

    private init() {
        var photos: [NaturePhoto] = []

        for location in NatureLocation.allCases {
            for i in 1...location.photoCount {
                let assetName = "\(location.assetPrefix)_\(i)"
                photos.append(NaturePhoto(
                    id: assetName,
                    location: location,
                    index: i
                ))
            }
        }

        allPhotos = photos
    }

    /// Get all photos for a specific location
    func photos(for location: NatureLocation) -> [NaturePhoto] {
        allPhotos.filter { $0.location == location }
    }
}
