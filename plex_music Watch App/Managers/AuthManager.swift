//
//  AuthManager.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/30/24.
//

import Foundation


class AuthViewModel: ObservableObject {
    @Published var pinCode: String?
    @Published var pinId: Int?
    @Published var authToken: String?
    @Published var serverURI: String?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isCheckingAuth = false
    @Published var serverAddresses = [AddressPretty]()
    
    private var authCheckTimer: Timer?
    
    init() {
        if let token = getLocalAuthToken() {
            authToken = token
        } else {
            print("No local token.")
            return
        }
        
        if let uri = getLocalURI() {
            serverURI = uri
        } else {
            print("No local server. Load the list")
            getServerURI()
        }
        
        
        //        /library/parts/54014/1566510562/file.flac
        //        guard let authToken = getLocalAuthToken() else {
        //            return
        //        }
        //        streamMusic(trackKey: "/library/parts/54014/1566510562/file.flac", serverUri: "http://104.15.219.181:32400", authToken: authToken)
        //        let musicStreamer = MusicStreamer()
        //        if let audioUrl = URL(string: "http://104.15.219.181:32400/library/parts/54014/1566510562/file.flac") {
        //            musicStreamer.streamMusic(from: audioUrl, authToken: authToken)
        //        }
    }
    
    /// Requests a PIN to be used with plex.tv/link
    func getPin() {
        isCheckingAuth = false
        NetworkManager.shared.requestPin { pinCode, pinId, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error getting pin: \(error.localizedDescription)"
                    self.isCheckingAuth = false
                } else {
                    self.pinCode = pinCode
                    self.pinId = pinId
                    self.startAuthCheckTimer()
                    self.isCheckingAuth = true
                }
            }
        }
    }
    
    /// Checks to see if the pin has been authenticated
    func checkPinAuthentication() {
        guard let pinId = pinId, authToken == nil else {
            self.errorMessage = "PIN ID not available or already authenticated."
            return
        }
        
        isCheckingAuth = true
        NetworkManager.shared.checkPinAuthentication(pinId: pinId) { authToken, error in
            DispatchQueue.main.async {
                if let authToken = authToken {
                    print("PIN authenticated! Auth Token is ", authToken)
                    self.isCheckingAuth = false
                    self.authCheckTimer?.invalidate()
                    self.authCheckTimer = nil
                    self.saveAuthToken(token: authToken)
                    self.getServerURI()
                } else if let error = error {
                    self.errorMessage = "Error checking pin: \(error.localizedDescription)"
                    self.isCheckingAuth = false
                }
            }
        }
    }
    
    private func startAuthCheckTimer() {
        authCheckTimer?.invalidate()
        authCheckTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            self?.checkPinAuthentication()
        }
    }
    
    
    
    func getLibraries() {
        guard let authToken = getLocalAuthToken() else {
            return
        }
        guard let uri = getLocalURI() else {
            return
        }
        print("getting libraries")
        NetworkManager.shared.getLibraries(authToken: authToken, uri: uri) { libraries, error in
            DispatchQueue.main.async {
                if let libraries = libraries {
                    print("libraries", libraries)
                } else if let error = error {
                    print("Failed to fetch libraries: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getServerURI() {
        guard let authToken = getLocalAuthToken() else {
            return
        }
        NetworkManager.shared.getServers(authToken: authToken) { addresses, error in
            DispatchQueue.main.async {
                if let addresses = addresses {
                    for address in addresses {
                        print(address.address)
                        let aP = AddressPretty(id: address.address, address: address.address, port: address.port, isExternal: address.external)
                        self.serverAddresses.append(aP)
                        print(aP.address)
                    }
                } else if let error = error {
                    print("Failed to fetch addresses: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    func getLibraryItems() {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            return
        }
        NetworkManager.shared.getLibraryItems(authToken: authToken, serverUri: "http://104.15.219.181:32400", sectionId: "3") { artistData, error in
            DispatchQueue.main.async {
                if let details = artistData {
                    print("Details")
                    for data in details {
                        print(data.title! as String)
                        print(data.ratingKey! as String)
                    }
                } else if let error = error {
                    print("Failed to fetch addresses: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getItemChildren() {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            return
        }
        //hans zimmer
        //44926
        //the holiday
        // 45302
        // the cowch
        // 45320
        NetworkManager.shared.getItemChildren(authToken: authToken, serverUri: "http://104.15.219.181:32400", ratingKey: "45302") { details, error in
            DispatchQueue.main.async {
                if let details = details {
                    //                    print("Fetched item Metadata successfully: \(details)")
                    if let mdata = details.Metadata {
                        for data in mdata {
                            print(data.title)
                            print(data.Media!.first!.Part!.first?.key)
                        }
                    }
                } else if let error = error {
                    print("Error fetching item details: \(error.localizedDescription)")
                }
            }
        }
        
    }
    func setServerURI(uri: String) {
        saveServerURI(uri: uri)
        serverURI = uri
    }
    
    private func saveServerURI(uri: String) {
        UserDefaults.standard.set(uri, forKey: "plexServerURI")
//        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
//            return
//        }
//
//        NetworkManager.shared.getDevices(authToken: authToken) { device, error in
//            DispatchQueue.main.async {
//                if let device = device, let uri = device.publicAddress {
//                    print("Public URI:", uri)
//                    UserDefaults.standard.set(uri, forKey: "plexServerURI")
//                    self.getServerURI()
//                } else if let error = error {
//                    print("Failed to fetch devices: \(error.localizedDescription)")
//                }
//            }
//        }
    }
    
    /// Saves the authToken to [UserDefaults] for quick retrieval later
    private func saveAuthToken(token: String) {
        authToken = token
        UserDefaults.standard.set(token, forKey: "authToken")
    }


    private func getLocalAuthToken() -> String? {
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            authToken = token
            print("Loaded authToken from UserDefaults")
            return token
        } else {
            return nil
        }
    }
    
    private func getLocalURI() -> String? {
        return UserDefaults.standard.string(forKey: "plexServerURI")
    }
}
