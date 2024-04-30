//
//  AudioManager.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/29/24.
//

import Foundation
import AVFoundation

//var player: AVPlayer?
//
//func streamMusic(trackKey: String, serverUri: String, authToken: String) {
//    let urlString = "\(serverUri)\(trackKey)"
//    guard let url = URL(string: urlString) else {
//        print("Invalid URL")
//        return
//    }
//    
//    var request = URLRequest(url: url)
//    request.addValue("application/json", forHTTPHeaderField: "Accept")
//    request.addValue(authToken, forHTTPHeaderField: "X-Plex-Token")
//
//    // Use URLSession to download the media file data
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        guard let data = data, error == nil else {
//            print("Failed to download file: \(error?.localizedDescription ?? "No error description available")")
//            return
//        }
//        // Create a file URL to save the downloaded data
//        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".flac")
//        print("temp URL: \(tempUrl)")
//        do {
//            try data.write(to: tempUrl)
//            DispatchQueue.main.async {
//                // Play the file using AVPlayer
//                player = AVPlayer(url: tempUrl)
//                player?.play()
//            }
//        } catch {
//            print("Failed to write file to disk: \(error.localizedDescription)")
//        }
//    }
//    task.resume()
//}

import AVFoundation

class MusicStreamer: NSObject {
    var player: AVPlayer?

    func streamMusic(from url: URL, authToken: String) {
        print("running stream music function")
        
        let audioSession = AVAudioSession()
        do {
            try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
        } catch {
            print("audisession cannot be set")
        }
        
        do {
            try audioSession.setActive(true)
        } catch {
            print ("could not set active")
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        // Initialize the AVPlayer with the URL
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? []
        queryItems.append(URLQueryItem(name: "X-Plex-Token", value: authToken))
        urlComponents?.queryItems = queryItems
        guard let finalURL = urlComponents?.url else {
            print("invalid url")
            return
        }
        let playerItem = AVPlayerItem(url: finalURL)
        
        self.player = AVPlayer(playerItem: playerItem)
//        self.player?.play()

        // Add observer to start playing as soon as the player is ready
        self.player?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
    }

    // Observer response method
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            
                print(player?.status)
            if player?.status == .readyToPlay {
                print("attempting to play audio")
                player?.play()
            } else if player?.status == .failed {
                // Handle failure (e.g., create an error log or alert)
                print("Failed to load the audio")
            } else {
                print(player?.status)
            }
        }
    }

    // Deinitialization to remove observer
    deinit {
        player?.removeObserver(self, forKeyPath: "status")
    }
}

