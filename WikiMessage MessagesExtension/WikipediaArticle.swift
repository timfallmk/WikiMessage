//
//  WikipediaArticle.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 12/21/17.
//  Copyright © 2017 Tim Fall. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

struct Wikipedia {
	var title: String?
	var articleURL: URL?
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

var searchResults = [Wikipedia]()
var populated = Wikipedia()
let networkFunctions = NetworkFunctions()

func getArticleContents(article: Wikipedia) -> Wikipedia {
	populated = article
	firstly{
		let articleURL =  networkFunctions.fetchArticleURL(pageID: article.pageID!)
		populated.articleURL = articleURL.value?.articleURL
		return articleURL
	}.then { (wikipedia) -> Promise<Wikipedia> in
		let articleText = networkFunctions.fetchArticleText(pageID: article.pageID!)
		populated.fullText = articleText.value?.fullText
		return articleText
	}.then { (wikipedia) -> Wikipedia in
		return populated
	}.catch { (error) in
		debugPrint(error)
	}
}

func populateArticleURL(url: URL) {
	populated.articleURL = url
}

func populateArticleText(text: String){
	populated.fullText = text
}

// Given a text search query string, get a list of returned results
func searchForArticle(searchText: String) {
	var results = [Wikipedia]()
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
				let json = try JSON(data: data)
//				debugPrint(json)
				for i in 0..<json["query"]["search"].count {
					let article = json["query"]["search"][i].dictionary
//					debugPrint(article)
//					debugPrint(article!["pageid"])
					results.append(Wikipedia(title: article!["title"]?.string,
											 articleURL: nil,
											 pageID: article!["pageid"]?.int,
											 subjectLine: article!["snippet"]?.string,
											 summeryParagrah: nil,
											 fullText: nil,
											 subjectImageURL: nil))
				}
//				debugPrint(results[1])
//				debugPrint(json)
			}
			catch let error {
				debugPrint(error)
			}
		}
		else if let error = error {
			debugPrint(error)
		}
		DispatchQueue.main.async {
			setSearchResults(results: results)
		}
	}
	task.resume()
}

func setSearchResults(results: [Wikipedia]) {
	searchResults = results
}

func getSearchResults(searchText: String) -> [Wikipedia] {
	searchForArticle(searchText: searchText)
	return searchResults
}
