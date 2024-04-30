//
//  XMLParser.swift
//  plex_music Watch App
//
//  Created by Bain Gurley on 4/19/24.
//

import Foundation

class PlexXMLParser: NSObject, XMLParserDelegate {
    var authToken: String?
    private var currentElement = ""

    func parseAuthToken(data: Data) -> String? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return authToken
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        if elementName == "pin" && attributeDict["authToken"] != "" {
            authToken = attributeDict["authToken"]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "authToken" && !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            authToken = string
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Error: \(parseError.localizedDescription)")
    }
}

class AddressParser: NSObject, XMLParserDelegate {
    private var addresses = [Address]()
    private var port: Int?
    private var localAddresses: [String] = []

    func parse(data: Data) -> [Address] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return addresses
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Server" {
            if let portString = attributeDict["port"], let port = Int(portString) {
                self.port = port
            }
            if let localAddressesString = attributeDict["localAddresses"] {
                self.localAddresses = localAddressesString.split(separator: ",").map(String.init)
            }
            if let address = attributeDict["address"], let port = self.port {
                let https = attributeDict["scheme"] == "https"
                let external = !localAddresses.contains(address)
                addresses.append(Address(address: address, port: port, https: https, external: external))
                
                // Process local addresses
                localAddresses.forEach { localAddress in
                    addresses.append(Address(address: localAddress, port: port, https: https, external: false))
                }
            }
        }
    }
}


