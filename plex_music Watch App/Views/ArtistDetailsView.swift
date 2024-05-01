//
//  ArtistDetailsView.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 5/1/24.
//

import SwiftUI

struct ArtistDetailsView: View {
    @ObservedObject var viewModel: AuthViewModel
    var objectRatingKey: String
    var body: some View {
        Text("Hello World")
        .onAppear {
            print("appeared")
            viewModel.getItemChildren(ratingKey: objectRatingKey) {
                metadata, error in
                   if let metadata = metadata {
                       // process metadata
                       print(metadata)
                   } else if let error = error {
                       // handle error
                       print("Error: \(error.localizedDescription)")
                   }
            }
        }
    }
}



#Preview {
        ContentView()
}
