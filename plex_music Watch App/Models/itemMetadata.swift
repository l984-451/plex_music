//
//  itemMetadata.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/29/24.
//

import Foundation

struct ItemMetadataContainer: Codable {
    var MediaContainer: ItemMetadata?
}

struct ItemMetadata: Codable {
    var size: Int?
    var allowSync: Bool?
    var Metadata: [Metadata]?
}
