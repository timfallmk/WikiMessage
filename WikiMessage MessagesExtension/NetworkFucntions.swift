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
	func fetchArticleURL(url: URL) -> Promise<Wikipedia> {
		return Promise { fulfill, reject in
			let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
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
}

