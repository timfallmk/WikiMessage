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
		
		return Promise<Wikipedia> { fulfill, reject in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let article = json["query"]["pages"][0].dictionary
					let result = Wikipedia(title: article?["title"]?.string,
									   articleURL: article?["fullurl"]?.url,
									   pageID: article?["pageid"]?.int,
									   subjectLine: nil,
									   summeryParagrah: nil,
									   fullText: nil,
									   subjectImageURL: nil)
					fulfill(result)
				} catch {
					reject(error)
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
				if error != nil {
					reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let article = json["parse"].dictionary
					let result = Wikipedia(title: nil,
										   articleURL: nil,
										   pageID: article?["pageid"]?.int,
										   subjectLine: nil,
										   summeryParagrah: nil,
										   fullText: article?["text"]!.string,
										   subjectImageURL: nil)
					fulfill(result)
				} catch {
					reject(error)
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
		
		return Promise { fulfill, reject in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["thumbnail"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						let data = try? Data(contentsOf: sourceURL!)
						fulfill(UIImage(data: data!)!)
					} else {
						reject("No images found" as! Error)
					}
				} catch {
					reject(error)
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
		
		return Promise { fulfill, reject in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["thumbnail"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						fulfill(sourceURL!)
					} else {
						reject(NoThumbnailError.NoThumbnailError("No thumbnail found for \(data)"))
					}
				} catch {
					reject(error)
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
		
		return Promise { fulfill, reject in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["original"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						let data = try? Data(contentsOf: sourceURL!)
						fulfill(UIImage(data: data!)!)
					} else {
						reject("No images found" as! Error)
					}
				} catch {
					reject(error)
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
		
		return Promise { fulfill, reject in
			URLSession.shared.dataTask(with: components.url!) { (data, response, error) in
				if error != nil {
					reject(error!)
				}
				guard let data = data else { return }
				do {
					let json = try JSON(data: data)
					let thumbnails = json["query"]["pages"][0]["original"].dictionary
					if thumbnails?.isEmpty == false {
						let sourceURL = thumbnails?["source"]?.url
						fulfill(sourceURL!)
					} else {
						reject(NoThumbnailError.NoThumbnailError("No fullsize page image found for \(data)"))
					}
				} catch {
					reject(error)
				}
				}.resume()
		}
	}
	
	enum NoThumbnailError: Error {
		case NoThumbnailError(String)
	}
}

