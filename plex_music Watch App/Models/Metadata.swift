//
//  Metadata.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/29/24.
//

import Foundation

struct Metadata: Codable {
    var ratingKey: String?
    var key: String?
    var guid: String?
    var studio: String?
    var type: String?
    var title: String?
    var librarySectionTitle: String?
    var librarySectionID: Int?
    var librarySectionKey: String?
    var contentRating: String?
    var summary: String?
    var rating: Double?
    var audienceRating: Double?
    var year: Int?
    var tagline: String?
    var thumb: String?
    var art: String?
    var duration: Int?
    var originallyAvailableAt: String?
    var addedAt: Int?
    var updatedAt: Int?
    var audienceRatingImage: String?
    var hasPremiumPrimaryExtra: String?
    var ratingImage: String?
    // Parent fields
    var parentRatingKey: String?
    var parentGuid: String?
    var parentStudio: String?
    var parentKey: String?
    var parentTitle: String?
    var parentIndex: Int?
    var parentYear: Int?
    var parentThumb: String?
    var parentTheme: String?
    // Collection fields
    var index: Int?
    var viewCount: Int?
    var lastViewedAt: Int?
    var leafCount: Int?
    var viewedLeafCount: Int?
    var userRating: Int?
    var skipCount: Int?
    var lastRatedAt: Int?
    var Media: [Media]?
}

