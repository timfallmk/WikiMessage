//
//  WikipediaArticle.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 12/21/17.
//  Copyright © 2017 Tim Fall. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import PromiseKit
import AwaitKit

struct Wikipedia {
	var title: String?
	var articleURL: URL?
	var pageID: Int?
	var subjectLine: String?
	var summeryParagrah: String?
	var fullText: String?
	var subjectImageURL: URL?
	var previewImage: UIImage?
	
}

var searchResults = [Wikipedia]()
var populated = Wikipedia()
let networkFunctions = NetworkFunctions()

func getArticleContents(article: Wikipedia) -> Wikipedia {
	populated = article
	let articleURL = try! await(networkFunctions.fetchArticleURL(pageID: article.pageID!))
	populated.articleURL = articleURL.articleURL

	let articleText = try! await(networkFunctions.fetchArticleText(pageID: article.pageID!))
	populated.fullText = articleText.fullText
	
	// TODO: fix this to prepopulate images in the search list
//	let articleImage = try! await(networkFunctions.fetchArticleThumbURL(pageID: article.pageID!))
//	populated.subjectImageURL = articleImage
	return populated
}

func populateArticleURL(url: URL) {
	populated.articleURL = url
}

func populateArticleText(text: String){
	populated.fullText = text
}

func getSearchResults(searchText: String) -> [Wikipedia] {
	let results = try! await(networkFunctions.searchForArticle(searchText: searchText))
	return results
}

func getPreviewImagesURL(articles: [Wikipedia]) -> [Wikipedia] {
	var list = articles
	for i in 0..<list.count {
		guard let url = try? await(networkFunctions.fetchArticleThumbURL(pageID: list[i].pageID!)) else {
			list[i].subjectImageURL = nil
			break
		}
		list[i].subjectImageURL = url
	}
	return list
}

// As suspected, this needs to be asyncronous to not drag everything to a halt
// TODO: Make this asyncronous and cached then update results when loaded
func getPreviewImages(articles: [Wikipedia]) -> [Wikipedia] {
	var list = articles
	for i in 0..<list.count {
		guard let image = try? await(networkFunctions.fetchArticleThumb(pageID: list[i].pageID!)) else {
			list[i].previewImage = UIImage()
			break
		}
		list[i].previewImage = image
	}
	return list
}
