//
//  ArtistListView.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/30/24.
//

import SwiftUI

var artists = [
Artist(id: "Artist 01", name: "Artist 01", Metadata: nil),
Artist(id: "Artist 02", name: "Artist 02", Metadata: nil),
Artist(id: "Artist 03", name: "Artist 03", Metadata: nil),
Artist(id: "Artist 04", name: "Artist 04", Metadata: nil),
]

struct ArtistListView: View {
    var body: some View {
        NavigationView {
            List(artists) {artist in
                HStack {
                    Text(artist.name)
                    Spacer()
                    Image(artist.Metadata?.art ?? "placeholder_artist")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .colorInvert()
                }
            }
            .navigationTitle("Artists")
        }
    }
}

#Preview {
    ArtistListView()
}
