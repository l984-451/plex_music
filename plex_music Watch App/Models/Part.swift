//
//  Part.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/30/24.
//

import Foundation

struct Part: Codable {
    var id: Int?
    var key: String?
    var duration: Int?
    var file: String?
    var size: Int?
    var container: String?
    var hasThumbnail: String?
}
