//
//  AuthView.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/30/24.
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            if viewModel.authToken != nil {
                Text("Authenticated successfully!")
            } else if let pinCode = viewModel.pinCode {
                VStack {
                    Text("Your PIN is: \(pinCode)")
                    Text("Please enter this PIN at plex.tv/link to authenticate.")
                }
            } else if let error = viewModel.errorMessage {
                Text("An error occurred:")
                Text(error)
            } else {
                Text("Authenticate with Plex")
            }
            
            if viewModel.isCheckingAuth {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if viewModel.pinCode == nil && viewModel.authToken == nil {
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
