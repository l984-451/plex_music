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

struct Address: Codable {
    let address: String
    let port: Int
    let https: Bool
    let external: Bool
}

struct LibraryContainer: Codable {
    let MediaContainer: LibraryMediaContainer
}

struct LibraryMediaContainer: Codable {
    let size: Int
    let title1: String
    let Directory: [Library]
}

struct Library: Codable {
    let key: String
    let type: String
    let title: String
    let agent: String
    let scanner: String
    let language: String
    let uuid: String
    let updatedAt: Int
    let createdAt: Int
    let scannedAt: Int
    let Location: [LibraryLocation]
}

struct LibraryLocation: Codable {
    let id: Int
    let path: String
}

struct LibraryDetail: Codable {
    let size: Int?
    let allowSync: Bool?
    let art: String?
    let content: String?
    let identifier: String?
    let librarySectionID: Int?
    let mediaTagPrefix: String?
    let mediaTagVersion: Int?
    let thumb: String?
    let title1: String?
    let viewGroup: String?
    let viewMode: Int?
    let Directory: [LibraryDirectory]?
    let `Type`: [LibraryType]?
}

struct LibraryDirectory: Codable {
    let key: String?
    let title: String?
    let secondary: Bool?
    let prompt: String?
    let search: Bool?
}

struct LibraryType: Codable {
    let key: String?
    let type: String?
    let title: String?
    let active: Bool?
    let Filter: [LibraryFilter]
    let Sort: [LibrarySort]
    let Field: [LibraryField]
}

struct LibraryFilter: Codable {
    let filter: String?
    let filterType: String?
    let key: String?
    let title: String?
    let type: String?
}

struct LibrarySort: Codable {
    let `default`: String?
    let defaultDirection: String?
    let descKey: String?
    let key: String?
    let title: String?
}

struct LibraryField: Codable {
    let key: String?
    let title: String?
    let type: String?
}

struct LibraryDetailContainer: Codable {
    var MediaContainer: MediaContainer
}

struct MediaContainer: Codable {
    var size: Int?
    var Metadata: [ArtistMetadata]?
}

struct ArtistMetadata: Codable {
    var ratingKey: String?
    var key: String?
    var title: String?
    var thumb: String?
    var art: String?
    var summary: String?
    // Include any other artist-specific details you need.
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
//        /library/parts/54014/1566510562/file.flac
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            return
        }
//        streamMusic(trackKey: "/library/parts/54014/1566510562/file.flac", serverUri: "http://104.15.219.181:32400", authToken: authToken)
        let musicStreamer = MusicStreamer()
        if let audioUrl = URL(string: "http://104.15.219.181:32400/library/parts/54014/1566510562/file.flac") {
            musicStreamer.streamMusic(from: audioUrl, authToken: authToken)
        }
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
                    self.getServers()
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
    
    func getServers() {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            return
        }
        guard let uri = UserDefaults.standard.string(forKey: "plexServerURI") else {
            return
        }
        NetworkManager.shared.getServers(authToken: authToken, uri: uri) { addresses, error in
            DispatchQueue.main.async {
                if let addresses = addresses {
                    for address in addresses {
                        print(address.address)
                        print(address.external)
                    }
                    self.getLibraries()
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
    
   


    private func loadAuthToken() {
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            isAuthenticated = true
            print("Loaded authToken locally:", token)
            authToken = token
//            getLibraryItems()
//            getItemChildren()
            
//            saveServerURI()

        }
    }
    
    func loadServerURI() -> String? {
        return UserDefaults.standard.string(forKey: "plexServerURI")
    }
}
