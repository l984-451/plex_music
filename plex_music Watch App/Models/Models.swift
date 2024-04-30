//
//  Models.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/19/24.
//

import Foundation
import Combine



struct PlexAPI {
    static let baseUrl = "https://plex.tv"
    static let clientIdentifier = "com.gstudios.plexwatch"
    static let deviceName = "plexWatchMusic"
}
struct Device: Codable {
    let name: String
    let product: String
    let productVersion: String
    let platform: String
    let platformVersion: String
    let device: String
    let clientIdentifier: String
    let createdAt: String
    let lastSeenAt: String
    let provides: String
    let ownerId: String?
    let sourceTitle: String?
    let publicAddress: String?
    let accessToken: String?
    let owned: Bool?
    let home: Bool?
    let synced: Bool?
    let relay: Bool?
    let presence: Bool?
    let httpsRequired: Bool?
    let publicAddressMatches: Bool?
    let dnsRebindingProtection: Bool?
    let natLoopbackSupported: Bool?
    let connections: [Connection]
}

struct Connection: Codable {
    let protocolType: String
    let address: String
    let port: Int
    let uri: String
    let local: Bool
    let relay: Bool
    let IPv6: Bool

    enum CodingKeys: String, CodingKey {
        case protocolType = "protocol" // 'protocol' is a reserved keyword in Swift
        case address, port, uri, local, relay, IPv6
    }
}

struct Address: Codable {
    let address: String
    let port: Int
    let https: Bool
    let external: Bool
}

struct AddressPretty: Identifiable {
    let id: String
    let address: String
    let port: Int
    let isExternal: Bool
}

struct LibraryContainer: Codable {
    let MediaContainer: LibraryMediaContainer
}

struct LibraryMediaContainer: Codable {
    let size: Int
    let title1: String
    let Directory: [Library]
}

struct Library: Codable {
    let key: String
    let type: String
    let title: String
    let agent: String
    let scanner: String
    let language: String
    let uuid: String
    let updatedAt: Int
    let createdAt: Int
    let scannedAt: Int
    let Location: [LibraryLocation]
}

struct LibraryLocation: Codable {
    let id: Int
    let path: String
}

struct LibraryDetail: Codable {
    let size: Int?
    let allowSync: Bool?
    let art: String?
    let content: String?
    let identifier: String?
    let librarySectionID: Int?
    let mediaTagPrefix: String?
    let mediaTagVersion: Int?
    let thumb: String?
    let title1: String?
    let viewGroup: String?
    let viewMode: Int?
    let Directory: [LibraryDirectory]?
    let `Type`: [LibraryType]?
}

struct LibraryDirectory: Codable {
    let key: String?
    let title: String?
    let secondary: Bool?
    let prompt: String?
    let search: Bool?
}

struct LibraryType: Codable {
    let key: String?
    let type: String?
    let title: String?
    let active: Bool?
    let Filter: [LibraryFilter]
    let Sort: [LibrarySort]
    let Field: [LibraryField]
}

struct LibraryFilter: Codable {
    let filter: String?
    let filterType: String?
    let key: String?
    let title: String?
    let type: String?
}

struct LibrarySort: Codable {
    let `default`: String?
    let defaultDirection: String?
    let descKey: String?
    let key: String?
    let title: String?
}

struct LibraryField: Codable {
    let key: String?
    let title: String?
    let type: String?
}

struct LibraryDetailContainer: Codable {
    var MediaContainer: MediaContainer
}

struct MediaContainer: Codable {
    var size: Int?
    var Metadata: [ArtistMetadata]?
}

struct ArtistMetadata: Codable {
    var ratingKey: String?
    var key: String?
    var title: String?
    var thumb: String?
    var art: String?
    var summary: String?
    // Include any other artist-specific details you need.
}




