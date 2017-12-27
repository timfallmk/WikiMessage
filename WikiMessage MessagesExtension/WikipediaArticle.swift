//
//  WikipediaArticle.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 12/21/17.
//  Copyright © 2017 Tim Fall. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Wikipedia {
	var title: String?
	var articleURL: String?
	var pageID: Int?
	var subjectLine: String?
	var summeryParagrah: String?
	var fullText: String?
	var subjectImageURL: String?
	
//	init(object: MarshaledObject) throws {
//		title = try object.value(for: "title")
//		pageID = try object.value(for: "pageid")
//	}
}

struct SearchResults {
	var results: [Int: Wikipedia]
}

func fetchGivenArticle(article: Wikipedia) {
	
}

// Given a text search query string, get a list of returned results
func searchForArticle(searchText: String) {
	var results: [String: Wikipedia]
	var components = URLComponents()
	components.scheme = "https"
	components.host = "en.wikipedia.org"
	components.path = "/w/api.php"
	
	// Set some basic query parameters
	components.queryItems = [
		URLQueryItem(name: "action", value: "query"),
		URLQueryItem(name: "format", value: "json"),
		URLQueryItem(name: "list", value: "search"),
		// Don't show "interwiki links", only show absolute links
		URLQueryItem(name: "iwurl", value: "1"),
		// Include an extra section with just the returned page ID's
		URLQueryItem(name: "indexpageids", value: "1"),
		URLQueryItem(name: "utf8", value: "1"),
		// Get results in the latest format. Currently this is "2"
		URLQueryItem(name: "formatversion", value: "latest"),
		// Limit returned results to 10
		URLQueryItem(name: "srlimit", value: "10"),
		// Add the search text
		URLQueryItem(name: "srsearch", value: searchText)
	]
	
	
	
	// Construct the query from the given options and run the request
	let task = URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
		debugPrint(components.url!)
		if let data = data {
			do {
				let jsonSerialized = try JSONSerialization.jsonObject(with: data, options:[]) as? [[String: Any]]
				
				if let json = jsonSerialized {
//					debugPrint(json)
					if let query = json[0]["query"] as? [String: Any] {
						debugPrint(query)
						if let search = query["search"] as? [Int: Wikipedia] {
							debugPrint(search)
							debugPrint(search[4])
							for article in search {
								debugPrint(article)
								let articleDeSerialized = try JSONSerialization.data(withJSONObject: article, options: [])
								let articleSerialized = try JSONSerialization.jsonObject(with: articleDeSerialized, options: [])
								
								debugPrint(articleSerialized)
							}
//							let articles = try search.map { key, value in
//								debugPrint(key, value)
//								var article = Wikipedia()
//								article.title = key
//								debugPrint(article)
//							}
						}
					}
				}
			}
			catch let error {
				debugPrint(error)
			}
		}
		else if let error = error {
			debugPrint(error)
		}
	}
	task.resume()

}
	

