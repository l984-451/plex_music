//
//  Media.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/29/24.
//

import Foundation

struct Media: Codable {
    var id: Int?
    var duration: Int?
    var bitrate: Int?
    var audioChannels: Int?
    var audioCodec: String?
    var container: String?
    var Part: [Part]?
}
