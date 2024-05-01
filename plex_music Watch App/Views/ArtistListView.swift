//
//  ArtistListView.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/30/24.
//

import SwiftUI

struct ArtistListView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.Artists) {artist in
                NavigationLink(destination: ArtistDetailsView(viewModel: viewModel, objectRatingKey: artist.ratingKey ?? "")) {
                    HStack {
                        Text(artist.title ?? "")
                        Spacer()
                        Image(artist.art != nil ? "\(viewModel.serverURI!)\(artist.art!)" : "placeholder_artist")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
    //                        .colorInvert()
                    }
                }
            }
            .navigationTitle("Artists")
        }
    }
}

#Preview {
    ContentView()
}
