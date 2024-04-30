//
//  ContentView.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/19/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MusicViewModel()

    var body: some View {
//        if viewModel.isAuthenticated {
//            NavigationView {
//                List(viewModel.artists) { artist in
//                    NavigationLink(destination: AlbumView(artistId: artist.id)) {
//                        Text(artist.name)
//                    }
//                }
//                .navigationTitle("Artists")
//                .onAppear {
//                    viewModel.fetchArtists()
//                }
//                if viewModel.isLoading {
//                    ProgressView("Loading...")
//                }
//                if let errorMessage = viewModel.errorMessage {
//                    Text(errorMessage)
//                }
//            }
//        } else {
            AuthenticationView(viewModel: viewModel)
//        }
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

struct AuthenticationView: View {
    @ObservedObject var viewModel: MusicViewModel

    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                Text("Authenticated successfully!")
                // You might want to navigate away or change the view upon successful authentication
            } else if let pinCode = viewModel.pinCode {
                VStack {
                    Text("Your PIN is: \(pinCode)")
                    Text("Please enter this PIN at plex.tv/link to authenticate.")
                }
            } else {
                Text("Authenticate with Plex")
            }
            
            if viewModel.isCheckingAuth {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if viewModel.pinCode == nil && !viewModel.isAuthenticated {
                Spacer()
                Button("Get PIN") {
                    viewModel.getPin()
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
