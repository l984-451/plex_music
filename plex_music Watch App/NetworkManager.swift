//
//  NetworkManager.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/19/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseUrl = "https://your-plex-server:32400"
    private let token = "YOUR_PLEX_TOKEN"

    func fetchArtists(completion: @escaping ([Artist]) -> Void) {
        let url = URL(string: "\(baseUrl)/library/sections/1/all?X-Plex-Token=\(token)")!
        
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
                print("JSON error: \(error.localizedDescription)")
            }
        }.resume()
    }

}
