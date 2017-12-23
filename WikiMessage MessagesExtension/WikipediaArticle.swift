//
//  WikipediaArticle.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 12/21/17.
//  Copyright © 2017 Tim Fall. All rights reserved.
//

import Foundation

struct Wikipedia {
	var title: String?
	var baseURL: URLComponents?
	var articleURL: URLComponents?
	var subjectLine: String?
	var summeryParagrah: String?
	var fullText: String?
	var subjectImageURL: URLComponents?
	
	init() {
		baseURL?.scheme = "https"
		baseURL?.host = "en.wikipedia.org"
		baseURL?.path = "/w/api.php"
	}
}

struct SearchResults {
	var results: [Int: Wikipedia]
}

func fetchGivenArticle(article: Wikipedia) {
	
}

// Given a text search query string, get a list of returned results
func searchForArticle(searchText: String) {
	var results: [String: Any]
	var request = URLComponents()
	
	// Set some basic listing parameters
	request.queryItems = [
		URLQueryItem(name: "action", value: "search"),
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
		URLQueryItem(name: "srlimit", value: "10")
	]
	
}
