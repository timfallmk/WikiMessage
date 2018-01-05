//
//  NetworkFucntions.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 1/2/18.
//  Copyright © 2018 Tim Fall. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

class NetworkFunctions {
	
	private func defaultAPIEndpoint() -> URLComponents {
		// MARK: API endpoint
		var components = URLComponents()
		components.scheme = "https"
		components.host = "en.wikipedia.org"
		components.path = "/w/api.php"
		return components
	}

	// MARK: Get the canonical URL for a specific article
	func fetchArticleURL(pageID: Int) -> Promise<Wikipedia> {
		
		let id = String(describing: pageID)
		
		var components = defaultAPIEndpoint()
		
		// MARK: Set query parameters for getting URL
		components.queryItems = [
			URLQueryItem(name: "action", value: "query"),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// Get the properies for a specific pageid
			URLQueryItem(name: "prop", value: "info"),
			// Get the full URL of the specified page
			URLQueryItem(name: "inprop", value: "url"),
			URLQueryItem(name: "pageids", value: id)
		]
		
		return Promise { fulfill, reject in
			let task = URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if let data = data,
					let json = try JSON(data: data),
					let article = json["query"]["pages"][0].dictionary,
					let result = Wikipedia(title: article?["title"]?.string,
									   articleURL: article?["fullurl"]?.url,
									   pageID: article?["pageid"]?.int,
									   subjectLine: nil,
									   summeryParagrah: nil,
									   fullText: nil,
									   subjectImageURL: nil) {
					fulfill(result)
				} else if let error = error {
					reject(error)
				} else {
					let error = Error(error)
					reject(error)
				}
			}
			task.resume()
		}
	}
	
	// MARK: Get the full source text (in WikiMarkup) for a given article
	func fetchArticleText(pageID: Int) -> Promise<Wikipedia> {
		
		let id = String(describing: pageID)
		
		var components = defaultAPIEndpoint()
		
		// MARK: Set query parameters for getting text
		components.queryItems = [
			URLQueryItem(name: "action", value: "parse"),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// Get the unparsed text for a specific pageid
			URLQueryItem(name: "pageids", value: id)
		]
		
		return Promise { fulfill, reject in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if let data = data,
					let json = try JSON(data: data),
					let article = json["parse"].dictionary,
					let result = Wikipedia(title: nil,
										   articleURL: nil,
										   pageID: article?["pageid"]?.int,
										   subjectLine: nil,
										   summeryParagrah: nil,
										   fullText: article?["text"]!.string,
										   subjectImageURL: nil) {
					fulfill(result)
				} else if let error = error {
					reject(error)
				} else {
					let error = Error(error)
					reject(error)
				}
			}
			task.resume()
		}
	}
}

