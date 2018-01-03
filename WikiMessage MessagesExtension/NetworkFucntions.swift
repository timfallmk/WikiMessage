//
//  NetworkFucntions.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 1/2/18.
//  Copyright © 2018 Tim Fall. All rights reserved.
//

import Foundation
import SwiftyJSON

class NetworkFunctions {
	typealias JSONCompletion = (JSON?) -> Void
	
	func fetchJSON(url: URL, completion: @escaping JSONCompletion) {
		URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
			switch response.result {
			case .success:
				if let data = data {
					let json = try JSON(data: data)
					completion(json)
				}
			case .failure(let error):
				debugPrint(error)
				completion(nil)
			}
		}).resume() {
			
		}
	}
}
