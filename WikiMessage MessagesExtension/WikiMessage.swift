//
//  WikiMessageCell.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 12/27/17.
//  Copyright © 2017 Tim Fall. All rights reserved.
//

import Foundation
import UIKit
import Messages
import AwaitKit

class WikipediaMessageCellView: UITableViewCell {
	
	// MARK: Properties
	
}

// MARK: Define a message from layout and contents
// TODO: Can't I put this all in a class? It doesn't seem to be able to access the 'Wikipedia' object when I do.

// Create a message from component parts
func createMessage(article: Wikipedia) -> MSMessage {
	let layout = MSMessageTemplateLayout()
	
	// Properties
	layout.caption = article.title
	layout.trailingCaption = article.subjectLine
	layout.image = pickImage(article: article)
	
	let message = MSMessage()
	message.layout = layout
	// Mark: URL set for message interaction
	message.url = article.articleURL
	
	return message
}

// Determine which image to use for the message layout
func pickImage(article: Wikipedia) -> UIImage {
	var image = UIImage()
	// TODO: Workaround for svgs. Should be fixed.
	let imageURL = try? await(networkFunctions.fetchArticleFullsizeImageURL(pageID: article.pageID!))
	// TODO: Fix this to get svg rendering working properly
	// If the fullsize page image is an svg, fall back to the thumbnail for now
	if (imageURL?.absoluteString.range(of: "svg") != nil ) {
		image = try! await(networkFunctions.fetchArticleThumb(pageID: article.pageID!))
		debugPrint("We found an svg! \(String(describing: imageURL?.absoluteString))")
		// TODO: Get this working
		// layout.image = pageImageFromSVG(svgURL: imageURL!)
	} else {
		let getImage = try? await(networkFunctions.fetchArticleFullsizeImage(pageID: article.pageID!))
		if getImage != nil {
			image = getImage!
		} else {
			image = #imageLiteral(resourceName: "articlePlaceholderImage")
		}
	}
	return image
}
