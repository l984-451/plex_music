//
//  itemChildren.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/29/24.
//

import Foundation

struct ItemChildrenContainer: Codable {
    var MediaContainer: ItemChildren?
}

struct ItemChildren: Codable {
    var size: Int?
    var allowSync: Bool?
    var art: String?
    var identifier: String?
    var key: String?
    var librarySectionID: Int?
    var librarySectionTitle: String?
    var librarySectionUUID: String?
    var mediaTagPrefix: String?
    var mediaTagVersion: Int?
    var nocache: Bool?
    var parentIndex: Int?
    var parentTitle: String?
    var parentYear: Int?
    var summary: String?
    var theme: String?
    var thumb: String?
    var title1: String?
    var title2: String?
    var viewGroup: String?
    var viewMode: Int?
    var directories: [Directory]?
    var metadata: [Metadata]?
}

struct Directory: Codable {
    var leafCount: Int?
    var thumb: String?
    var viewedLeafCount: Int?
    var key: String?
    var title: String?
}

