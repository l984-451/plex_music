//
//  LibraryModel.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/30/24.
//

import Foundation

struct Artist: Identifiable {
    var id: String
    var name: String
    var Metadata: Metadata?
}

struct Album: Identifiable {
    var id: String
    var title: String
    var artistId: String
}

struct Song: Identifiable {
    var id: String
    var title: String
    var albumId: String
    var streamUrl: String
}
