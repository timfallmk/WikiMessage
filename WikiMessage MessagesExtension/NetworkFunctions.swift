//
//  NetworkFucntions.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 1/2/18.
//  Copyright © 2018 Tim Fall. All rights reserved.
//

import Foundation
import UIKit
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
		
		return Promise<Wikipedia> { seal in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					seal.reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let article = json["query"]["pages"][0].dictionary
					let result = Wikipedia(title: article?["title"]?.string,
									   articleURL: article?["fullurl"]?.url,
									   pageID: article?["pageid"]?.int,
									   subjectLine: nil,
									   summeryParagraph: nil,
									   fullText: nil,
									   subjectImageURL: nil,
									   previewImage: nil)
					seal.fulfill(result)
				} catch {
					seal.reject(error)
				}
			}.resume()
		}
	}
	
	// MARK: Get the full source text (in WikiMarkup) for a given article
	func fetchArticleText(pageID: Int) -> Promise<Wikipedia> {
		
		let id = String(describing: pageID)
		
		var components = defaultAPIEndpoint()
		
		// MARK: Set query parameters for getting text
		components.queryItems = [
			URLQueryItem(name: "action", value: "query"),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// Get the "extract"ed text for a specific pageid
			URLQueryItem(name: "prop", value: "extracts"),
			// Limit us to the single extract for the given article
			URLQueryItem(name: "exlimit", value: "1"),
			// Only use plain text
			URLQueryItem(name: "explaintext", value: "1"),
			URLQueryItem(name: "exsectionformat", value: "plain"),
			URLQueryItem(name: "pageids", value: id)
		]
		
		return Promise { seal in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					seal.reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					// TODO: Swifty JSON doesn't seem to properly serialize number-only field strings in nested fields.
					// For example, "pages": { "222222":{ "pageid": "222222" produces no matches. Instead we assume here
					// that the first result returned is the correct one, since we're searching by pageid.
					// This should be looked into eventually.
					let article = json["query"]["pages"][0].dictionary
					let result = Wikipedia(title: nil,
										   articleURL: nil,
										   pageID: article?["pageid"]?.int,
										   subjectLine: nil,
										   summeryParagraph: article?["extract"]!.string,
										   fullText: article?["extract"]!.string,
										   subjectImageURL: nil,
										   previewImage: nil)
					seal.fulfill(result)
				} catch {
					seal.reject(error)
				}
			}.resume()
		}
	}
	
	// MARK: Check for thumbnail images and download them if found
	func fetchArticleThumb(pageID: Int) -> Promise<UIImage> {
		
		let id = String(describing: pageID)
		
		var components = defaultAPIEndpoint()
		
		// MARK: Set query parameters for getting thumbnails
		components.queryItems = [
			URLQueryItem(name: "action", value: "query"),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// Get the properies for a specific pageid
			URLQueryItem(name: "prop", value: "pageimages"),
			// Get the thumbnail image of the specified page
			URLQueryItem(name: "piprop", value: "thumbnail"),
			URLQueryItem(name: "pageids", value: id)
		]
		
		return Promise { seal in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					seal.reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["thumbnail"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						let data = try? Data(contentsOf: sourceURL!)
						seal.fulfill(UIImage(data: data!)!)
					} else {
						seal.reject(NoThumbnailError.NoThumbnailError("No images found!"))
					}
				} catch {
					seal.reject(error)
				}
				}.resume()
		}
	}
	
	func fetchArticleThumbURL(pageID: Int) -> Promise<URL> {
		
		let id = String(describing: pageID)
		
		var components = defaultAPIEndpoint()
		
		// MARK: Set query parameters for getting thumbnails
		components.queryItems = [
			URLQueryItem(name: "action", value: "query"),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// Get the properies for a specific pageid
			URLQueryItem(name: "prop", value: "pageimages"),
			// Get the thumbnail image of the specified page
			URLQueryItem(name: "piprop", value: "thumbnail"),
			URLQueryItem(name: "pageids", value: id)
		]
		
		return Promise { seal in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					seal.reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["thumbnail"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						seal.fulfill(sourceURL!)
					} else {
						seal.reject(NoThumbnailError.NoThumbnailError("No thumbnail found for \(data)"))
					}
				} catch {
					seal.reject(error)
				}
				}.resume()
		}
	}
	
	func fetchArticleFullsizeImage(pageID: Int) -> Promise<UIImage> {
		
		let id = String(describing: pageID)
		
		var components = defaultAPIEndpoint()
		
		// MARK: Set query parameters for getting thumbnails
		components.queryItems = [
			URLQueryItem(name: "action", value: "query"),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// Get the properies for a specific pageid
			URLQueryItem(name: "prop", value: "pageimages"),
			// Get the thumbnail image of the specified page
			URLQueryItem(name: "piprop", value: "original"),
			URLQueryItem(name: "pageids", value: id)
		]
		
		return Promise { seal in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					seal.reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["original"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						let data = try? Data(contentsOf: sourceURL!)
						seal.fulfill(UIImage(data: data!)!)
					} else {
						seal.reject(NoThumbnailError.NoThumbnailError("No images found"))
					}
				} catch {
					seal.reject(error)
				}
				}.resume()
		}
	}
	
	func fetchArticleFullsizeImageURL(pageID: Int) -> Promise<URL> {
		
		let id = String(describing: pageID)
		
		var components = defaultAPIEndpoint()
		
		// MARK: Set query parameters for getting thumbnails
		components.queryItems = [
			URLQueryItem(name: "action", value: "query"),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// Get the properies for a specific pageid
			URLQueryItem(name: "prop", value: "pageimages"),
			// Get the thumbnail image of the specified page
			URLQueryItem(name: "piprop", value: "original"),
			URLQueryItem(name: "pageids", value: id)
		]
		
		return Promise { seal in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					seal.reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["original"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						seal.fulfill(sourceURL!)
					} else {
						seal.reject(NoThumbnailError.NoThumbnailError("No fullsize page image found for \(data)"))
					}
				} catch {
					seal.reject(error)
				}
				}.resume()
		}
	}
	
	enum NoThumbnailError: Error {
		case NoThumbnailError(String)
	}
	
	// Given a text search query string, get a list of returned results
	func searchForArticle(searchText: String) -> Promise<[Wikipedia]> {
		
		var components = defaultAPIEndpoint()
		
		// Set some basic query parameters
		components.queryItems = [
			URLQueryItem(name: "action", value: "query"),
			URLQueryItem(name: "format", value: "json"),
//			URLQueryItem(name: "list", value: "search"),
			// Don't show "interwiki links", only show absolute links
			URLQueryItem(name: "iwurl", value: "1"),
			// Include an extra section with just the returned page ID's
			URLQueryItem(name: "indexpageids", value: "1"),
			URLQueryItem(name: "utf8", value: "1"),
			// Get results in the latest format. Currently this is "2"
			URLQueryItem(name: "formatversion", value: "latest"),
			// MARK: New search API
			// Use a generator to get all the information we need
			URLQueryItem(name: "generator", value: "prefixsearch"),
			// Get the properties we want in one go
			URLQueryItem(name: "prop", value: "pageimages|pageterms"),
			URLQueryItem(name: "piprop", value: "thumbnail"),
			URLQueryItem(name: "pilimit", value: "10"),
			URLQueryItem(name: "wbptterms", value: "description"),
			// Use the "prefixsearch" generator to search for conitnuing matches
			URLQueryItem(name: "gpssearch", value: searchText),
			URLQueryItem(name: "gpslimit", value: "10"),
			URLQueryItem(name: "gpsprofile", value: "fast-fuzzy")
			// Limit returned results to 10
//			URLQueryItem(name: "srlimit", value: "1"),
			// Get both the snippets for the title and the body
//			URLQueryItem(name: "srprop", value: "snippet|titlesnippet"),
			// Add the search text
//			URLQueryItem(name: "srsearch", value: searchText)
		]
		
		
		
		// Construct the query from the given options and run the request
		return Promise<[Wikipedia]> { seal in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				debugPrint(components.url!)
				if error != nil {
					seal.reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					//				debugPrint(json)
					var results = [Wikipedia]()
					for i in 0..<json["query"]["pages"].count {
						let article = json["query"]["pages"][i].dictionary
						//					debugPrint(article)
						//					debugPrint(article!["pageid"])
						var previewImage = UIImage()
						if article!["thumbnail"]?["source"].url != nil, let url = article!["thumbnail"]?["source"].url {
							let data = try? Data(contentsOf: url)
							previewImage = UIImage(data: data!)!
						}
						results.append(Wikipedia(title: article!["title"]?.string,
												 articleURL: nil,
												 pageID: article!["pageid"]?.int,
												 subjectLine: article!["terms"]?["description"][0].string,
												 summeryParagraph: nil,
												 fullText: nil,
												 subjectImageURL: article!["thumbnail"]?["source"].url ?? nil,
												 previewImage: previewImage))
					}
					seal.fulfill(results)
					//				debugPrint(results[1])
					//				debugPrint(json)
				} catch let error {
					seal.reject(error)
				}
			}.resume()
		}
		
	}
}

