//
//  ServerListView.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/30/24.
//

import SwiftUI

struct ServerListView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var selection: String?
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.serverAddresses, selection: $selection) {address in
                    HStack(content: {
                        VStack(alignment: .leading) {
                            Text(address.address)
                                .bold()
                            Text(verbatim: "Port: \(address.port)")
                            Text(address.isExternal ? "external" : "internal")
                        }
                        Spacer()
                        if address.address == selection {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    })
                    .onTapGesture {
                        selection = address.address
                    }
                    
                }
                .navigationTitle("Select an Address")
                Button(action: {
                    viewModel.serverURI = selection
                }){
                    Label("Next", systemImage: "arrow.right")
                }
                .background(.blue)
                .clipShape(Capsule())
                .controlSize(.mini)

            }
        }
    }
}

#Preview {
    ContentView()
}
