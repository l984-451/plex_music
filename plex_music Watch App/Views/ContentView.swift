//
//  ContentView.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/19/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authModel = AuthViewModel()

    var body: some View {
        if authModel.serverURI == nil && authModel.authToken != nil {
            ServerListView(viewModel: authModel)
        } else if authModel.serverURI != nil && authModel.authToken != nil {
            NavigationStack {
                ArtistListView()
            }
        } else {
            AuthenticationView(viewModel: authModel)
        }
    }
}

struct AlbumView: View {
    var artistId: String
    @State private var albums: [Album] = []

    var body: some View {
        List(albums) { album in
            NavigationLink(destination: SongView(albumId: album.id)) {
                Text(album.title)
            }
        }
        .navigationTitle("Albums")
        .onAppear {
            // Fetch albums for the artist
        }
    }
}

struct SongView: View {
    var albumId: String
    @State private var songs: [Song] = []

    var body: some View {
        List(songs) { song in
            Button(action: {
                // play the song
            }) {
                Text(song.title)
            }
        }
        .navigationTitle("Songs")
        .onAppear {
            // Fetch songs for the album
        }
    }
}



#Preview {
    ContentView()
}
