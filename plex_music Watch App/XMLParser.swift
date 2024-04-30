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
