//
//  NetworkManager.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/19/24.
//

import Foundation

extension JSONSerialization {
    
    static func loadJSON(withFilename filename: String) throws -> Any? {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            let data = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves])
            return jsonObject
        }
        return nil
    }
    
    static func save(jsonObject: Any, toFilename filename: String) throws -> Bool{
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            try data.write(to: fileURL, options: [.atomicWrite])
            return true
        }
        
        return false
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let token = "YOUR_PLEX_TOKEN"

    // Plex API keys
    private let plexApiPinUrl = "/pins.xml"
    private let plexApiPinCheckUrl = "/pins/{pinId}.xml"
    
    func fetchArtists(completion: @escaping ([Artist]) -> Void) {
        let url = URL(string: "\(PlexAPI.baseUrl)/library/sections/1/all?X-Plex-Token=\(token)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let mediaContainer = json["MediaContainer"] as? [String: Any],
                   let metadata = mediaContainer["Metadata"] as? [[String: Any]] {
                    let artists = metadata.map { Artist(id: $0["ratingKey"] as? String ?? "", name: $0["title"] as? String ?? "") }
                    DispatchQueue.main.async {
                        completion(artists)
                    }
                }
            } catch {
                print("FETCH ARTIST JSON error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func requestPin(completion: @escaping (String?, Int?, Error?) -> Void) {
        print("Requesting PIN from Plex API")
        let url = URL(string: "https://plex.tv/api/v2/pins")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(PlexAPI.clientIdentifier, forHTTPHeaderField: "X-Plex-Client-Identifier")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, nil, error)
                return
            }

            // Attempt to print the whole JSON response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(responseString)")
            }

            // Parse JSON to extract pinCode and pinId
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let pinId = json["id"] as? Int,
                   let pinCode = json["code"] as? String {
                    completion(pinCode, pinId, nil)
                } else {
                    print("Failed to parse JSON for pinId and pinCode")
                    completion(nil, nil, nil)
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(nil, nil, error)
            }
        }.resume()
    }
    
    func checkPinAuthentication(pinId: Int, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://plex.tv/api/v2/pins/\(pinId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(PlexAPI.clientIdentifier, forHTTPHeaderField: "X-Plex-Client-Identifier")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 400 {
                print("Authentication Error: PIN may not be valid or expired")
                completion(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Authentication error"]))
                return
            }

            let parser = PlexXMLParser()
            let authToken = parser.parseAuthToken(data: data)
            if let authToken = authToken, !authToken.isEmpty {
                completion(authToken, nil)
            } else {
                print("PIN not yet authenticated.")
                completion(nil, nil)  // PIN not authenticated, but no error occurred
            }
        }.resume()
    }
    
    func getServers(authToken: String, uri: String, completion: @escaping ([Address]?, Error?) -> Void) {
        guard let url = URL(string: "\(PlexAPI.baseUrl)/pms/servers.xml?includeLite=1") else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(authToken, forHTTPHeaderField: "X-Plex-Token")
        request.addValue(PlexAPI.clientIdentifier, forHTTPHeaderField: "X-Plex-Client-Identifier")
        request.addValue(PlexAPI.deviceName, forHTTPHeaderField: "X-Plex-Device")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            print("Got servers")
            let parser = AddressParser()
            let addresses = parser.parse(data: data)
            completion(addresses, error)
        }.resume()
    }
    
    func getDevices(authToken: String, completion: @escaping (Device?, Error?) -> Void) {
        guard let url = URL(string: "\(PlexAPI.baseUrl)/api/v2/resources") else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")    
        request.addValue(authToken, forHTTPHeaderField: "X-Plex-Token")
        request.addValue(PlexAPI.clientIdentifier, forHTTPHeaderField: "X-Plex-Client-Identifier")
        request.addValue(PlexAPI.deviceName, forHTTPHeaderField: "X-Plex-Device")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
//            print(String(data: data, encoding: .utf8) ?? "Invalid data")
//https://104-15-219-181.48ebbb1a9b1b40674de33b901f35dc2f72113b80.plex.direct:32400/web/index.html#!/login?redirectUrl=%2F
            do {
                let devices = try JSONDecoder().decode([Device].self, from: data)
//                print("devices:", devices)
                for device in devices {
                    if (device.provides == "server") {
                        print(device.clientIdentifier)
                        print(device.accessToken)
                        completion(device, nil)
                    }
                }
            } catch {
                print("DEVICES JSON Decoding Error: \(error)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getLibraries(authToken: String, uri: String, completion: @escaping ([Library]?, Error?) -> Void) {
//        guard let url = URL(string: "http://\(uri)/library/sections") else {
            guard let url = URL(string: "http://104.15.219.181:32400/library/sections") else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(authToken, forHTTPHeaderField: "X-Plex-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let container = try decoder.decode(LibraryContainer.self, from: data)
                completion(container.MediaContainer.Directory, nil)
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getLibraryDetails(authToken: String, serverUri: String, sectionId: String, completion: @escaping (LibraryDetail?, Error?) -> Void) {
        let urlString = "\(serverUri)/library/sections/\(sectionId)" // Make sure `sectionId` is not just a placeholder
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(authToken, forHTTPHeaderField: "X-Plex-Token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil, NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil))
                return
            }
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(LibraryDetail.self, from: data)
                completion(result, nil)
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil, error)
            }
        }.resume()
    }

    func getLibraryItems(authToken: String, serverUri: String, sectionId: String, completion: @escaping ([ArtistMetadata]?, Error?) -> Void) {
        let urlString = "\(serverUri)/library/sections/\(sectionId)/all"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(authToken, forHTTPHeaderField: "X-Plex-Token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil, NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil))
                return
            }
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let detailContainer = try decoder.decode(LibraryDetailContainer.self, from: data)
                if let metadata = detailContainer.MediaContainer.Metadata {
                    completion(metadata, nil)
                } else {
                    completion([], nil) // Return empty if there's no metadata
                }
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getItemChildren(authToken: String, serverUri: String, ratingKey: String, completion: @escaping (ItemMetadata?, Error?) -> Void) {
        let urlString = "\(serverUri)/library/metadata/\(ratingKey)/children"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(authToken, forHTTPHeaderField: "X-Plex-Token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil, NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil))
                return
            }
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(responseString)")
            }
            
            print("getting item children")
            do {
                let decoder = JSONDecoder()
                let container = try decoder.decode(ItemMetadataContainer.self, from: data)
                completion(container.MediaContainer, nil)
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil, error)
            }
        }.resume()
    }






    

    private func parseAuthToken(data: Data) -> String? {
        // Parse XML to find the auth token
        return nil // Implement actual parsing logic here
    }

}



