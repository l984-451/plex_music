//
//  Models.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/19/24.
//

import Foundation
import Combine

struct Artist: Identifiable {
    var id: String
    var name: String
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

struct PlexAPI {
    static let baseUrl = "https://plex.tv"
    static let clientIdentifier = "com.gstudios.plexwatch"
    static let deviceName = "plexWatchMusic"
}
struct Device: Codable {
    let name: String
    let product: String
    let productVersion: String
    let platform: String
    let platformVersion: String
    let device: String
    let clientIdentifier: String
    let createdAt: String
    let lastSeenAt: String
    let provides: String
    let ownerId: String?
    let sourceTitle: String?
    let publicAddress: String?
    let accessToken: String?
    let owned: Bool?
    let home: Bool?
    let synced: Bool?
    let relay: Bool?
    let presence: Bool?
    let httpsRequired: Bool?
    let publicAddressMatches: Bool?
    let dnsRebindingProtection: Bool?
    let natLoopbackSupported: Bool?
    let connections: [Connection]
}

struct Connection: Codable {
    let protocolType: String
    let address: String
    let port: Int
    let uri: String
    let local: Bool
    let relay: Bool
    let IPv6: Bool

    enum CodingKeys: String, CodingKey {
        case protocolType = "protocol" // 'protocol' is a reserved keyword in Swift
        case address, port, uri, local, relay, IPv6
    }
}





class MusicViewModel: ObservableObject {
    @Published var pinCode: String?
    @Published var pinId: Int?
    @Published var authToken: String?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isCheckingAuth = false

    private var authCheckTimer: Timer?
    
    init() {
         loadAuthToken()
     }

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
    
    func checkPinAuthentication() {
        guard let pinId = pinId, !isAuthenticated else {
            self.errorMessage = "PIN ID not available or already authenticated."
            return
        }
        
        isCheckingAuth = true
        NetworkManager.shared.checkPinAuthentication(pinId: pinId) { authToken, error in
            DispatchQueue.main.async {
                if let authToken = authToken {
                    print("PIN authenticated! Auth Token is ", authToken)
                    self.isAuthenticated = true
                    self.isCheckingAuth = false
                    self.authCheckTimer?.invalidate()
                    self.authCheckTimer = nil
                    self.saveAuthToken(authToken)
                    self.saveServerURI()
                } else if let error = error {
                    self.errorMessage = "Error checking pin: \(error.localizedDescription)"
                    self.isCheckingAuth = false
                } else {
                    // Continue checking; do not change isCheckingAuth to false yet.
                }
            }
        }
    }

    private func startAuthCheckTimer() {
        authCheckTimer?.invalidate()  // Ensure any existing timer is stopped before starting a new one.
        authCheckTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            self?.checkPinAuthentication()
        }
    }
    
    private func saveAuthToken(_ token: String) {
        authToken = token
        UserDefaults.standard.set(token, forKey: "authToken")
    }

    func saveServerURI() {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            return
        }

        NetworkManager.shared.getDevices(authToken: authToken) { device, error in
            DispatchQueue.main.async {
                if let device = device, let uri = device.publicAddress {
                    print("Public URI:", uri)
                    UserDefaults.standard.set(uri, forKey: "plexServerURI")
                    self.getLibraries()
                } else if let error = error {
                    print("Failed to fetch devices: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getLibraries() {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            return
        }
        guard let uri = UserDefaults.standard.string(forKey: "plexServerURI") else {
            return
        }
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

    private func loadAuthToken() {
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            isAuthenticated = true
            print("Loaded authToken locally:", token)
            authToken = token
            
            saveServerURI()
        }
    }
    
    func loadServerURI() -> String? {
        return UserDefaults.standard.string(forKey: "plexServerURI")
    }
}
