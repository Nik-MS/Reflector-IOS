//
//  articleXMLParser.swift
//  ReflectorIOS
//
//  Created by Nikhil Menon on 4/7/20.
//  Copyright © 2020 Nikhil Menon. All rights reserved.
//

import Foundation
import SwiftUI


protocol Parser {
    associatedtype ParsedObjectType
    func parse(data: Data) -> ParsedObjectType
}

/// Parses the XML Articles that are retrieved from RSSService.
final class ArticleXMLParser: NSObject, Parser, XMLParserDelegate {
    private var objects: [Article]
    private var object: Article!
    private var currentContent: String = String()
    
    enum XMLHelperError: Error {
        case invalidDataInput
    }
    
    public var data: Data!
    
    // MARK: - Init Method
    override required init() {
        self.objects = []
        super.init()
    }
    
    // MARK: - Parse Method
    
    /// parse takes in a type `Data` and will attempt to decode. This function will return a type `[Article]`
    func parse(data: Data) -> [Article] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        self.object = Article()
        
        if !parser.parse() {
            print("Data Errors exist in XML. could not parse.")
        }
        return self.objects
    }
    
    
    // MARK: - XMLParser Delegate Methods
    // All of these methods below are from the XMLParserDelegate and are called as Swift attempts to decode XML data.
    // These methods should not be tampered with.
    // Sauce: https://makeapppie.com/2016/06/06/how-to-read-xml-files-from-the-web-in-swift/
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("Starting to Parse")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case Article.tags.item.rawValue:
            object = Article()
            self.currentContent = ""
            break
            
        default:
            self.currentContent = ""
        }
        
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentContent += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        switch elementName {
            
        case Article.tags.item.rawValue:
            objects.append(object)
            break
        case Article.tags.title.rawValue:
            object.title = currentContent
            break
        case Article.tags.description.rawValue:
            object.details = currentContent
            break
        case Article.tags.pubDate.rawValue:
            object.pubDate = currentContent
            break
        case Article.tags.link.rawValue:
            object.link = currentContent
            break
        case Article.tags.creator.rawValue:
            object.creator = currentContent
            break
            
        default: return
        }
    }
}