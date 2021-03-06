//
//  MessagesViewController.swift
//  WikiMessage MessagesExtension
//
//  Created by Tim Fall on 12/13/17.
//  Copyright © 2017 Tim Fall. All rights reserved.
//

import UIKit
import Messages
import SafariServices
import AwaitKit
import Kingfisher
import Whisper

class MessagesViewController: MSMessagesAppViewController, UITableViewDataSource, UITableViewDelegate {
	
    // MARK: Properties
    @IBOutlet weak var appSplashLabel: UILabel!
	@IBOutlet var tableView: UITableView!
	
	
	// MARK: Storage variables
	let searchController = UISearchController(searchResultsController: nil)
	var displayArray = [Wikipedia]()
	var blankDisplay = Array(repeating: "p", count: 12)
	var webView: SFSafariViewController?
	let activity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
	let progress = UIProgressView()
	let notificationViewController = UIViewController()
	let notificationView = UIView()
	let networkOfflineNotification = Announcement(title: "Connection", subtitle: "Network appears to be offline", image: #imageLiteral(resourceName: "notificationIcon"), duration: 2, action: nil)
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		// Mark: Setup search controller
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Wikipedia"
		searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
		navigationItem.searchController = searchController
		// Have to do this the pre-iOS 11.0 way if there's no navigation item
		tableView.tableHeaderView = searchController.searchBar
		searchController.searchBar.delegate = self
		// Change the background from transparent to white to prevent cells from being shown when scrolled
		// under the search bar itself.
		// TODO: This is hacky and should be fixed.
		searchController.searchBar.backgroundColor = .white
		searchController.searchBar.addSubview(activity)
		
		// Mark: Setup notification area
		notificationViewController.view = notificationView
		// We have to do it this way because we can't get access to the main UIViewController
		tableView.tableFooterView = notificationView
		
		
		// TODO: Progress bar work
//		searchController.searchBar.addSubview(progress)
//		progress.center = CGPoint(x: (searchController.searchBar.frame.midX), y: searchController.searchBar.frame.midY)
//		progress.bounds = CGRect(x: (searchController.searchBar.frame.minX), y: (searchController.searchBar.frame.minY), width: (searchController.searchBar.frame.width), height: (searchController.searchBar.frame.height) )
//		progress.transform = progress.transform.scaledBy(x: 1.0, y: 20.0)
//		progress.trackTintColor = .gray

		searchController.searchBar.autoresizesSubviews = true
		
		// Set the position for the loading indicator
		activity.color = .blue
		activity.hidesWhenStopped = true
		activity.clipsToBounds = true
//		activity.color = .darkGray
		activity.translatesAutoresizingMaskIntoConstraints = false
		debugPrint(searchController.searchBar.rightAnchor, searchController.searchBar.leftAnchor)
		NSLayoutConstraint.activate([
			activity.rightAnchor.constraint(lessThanOrEqualTo: searchController.searchBar.rightAnchor, constant: -100.0),
			activity.centerYAnchor.constraint(equalTo: searchController.searchBar.centerYAnchor)])
		
		debugPrint(searchController.searchBar.subviews)
//		let view = UIView(
		definesPresentationContext = true
		debugPrint(displayArray, searchController)
		tableView.reloadData()
		
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
		
		// MARK: Display content in browser
		webView?.dismiss(animated: true, completion: nil)
		if let url = conversation.selectedMessage?.url {
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			config.barCollapsingEnabled = true
			webView = SFSafariViewController(url: url, configuration: config)
			present(webView!, animated: true, completion: nil)
		}
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
		
		// MARK: Display content in browser
		guard presentationStyle == .expanded else { return }
		if let message = activeConversation?.selectedMessage, let url = message.url {
			webView = SFSafariViewController(url: url)
			present(webView!, animated: true, completion: nil)
		}
		searchController.searchBar.becomeFirstResponder()
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
	
	
	// MARK: Table View
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchBarIsEmpty() {
			return 0
		} else if isFiltering() {
			return displayArray.count
		}
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		// MARK: Table Population Logic
		let searchResult: Wikipedia
		if isFiltering() {
			searchResult = displayArray[indexPath.row]
		} else {
			return cell
		}
		async {
			cell.textLabel?.text = searchResult.title
			cell.detailTextLabel?.text = searchResult.subjectLine
			
			// Kingfisher image fetch and caching settings
			cell.imageView?.kf.indicatorType = .activity
			
//			let image: UIImage? = searchResult.previewImage
//			if image?.ciImage != nil || image?.cgImage != nil {
//				cell.imageView?.image = searchResult.previewImage
//				cell.imageView?.contentMode = .right
//				cell.imageView?.autoresizingMask = .flexibleLeftMargin
//			} else {
//				cell.imageView?.image = UIImage(named: "articlePlaceholderImage")
//				cell.imageView?.kf.setImage(with: searchResult.subjectImageURL, placeholder: #imageLiteral(resourceName: "articlePlaceholderImage") as Placeholder, options: [.transition(.fade(0.2))])
//
//				cell.imageView?.contentMode = .center
//				cell.imageView?.autoresizingMask = .flexibleLeftMargin
//			}
			cell.imageView?.kf.indicator?.startAnimatingView()
			cell.imageView?.image = UIImage(named: "articlePlaceholderImage")
			cell.imageView?.kf.setImage(with: searchResult.subjectImageURL, placeholder: #imageLiteral(resourceName: "articlePlaceholderImage") as Placeholder, options: [.transition(.fade(0.2))])
			
			cell.imageView?.contentMode = .scaleAspectFill
			cell.imageView?.autoresizingMask = .flexibleLeftMargin
			cell.imageView?.kf.indicator?.stopAnimatingView()
			debugPrint(cell)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var article: Wikipedia
		article = displayArray[indexPath.row]
		let selected = getArticleContents(article: article)
//		debugPrint("This is article \(selected)", selected.subjectLine, article)
		
		let message = createMessage(article: selected)
		
		let conversation = activeConversation
		conversation!.insert(message) { error in
			if let error = error {
				print(error)
			}
		}
		
		requestPresentationStyle(.compact)
	}
	
	// MARK: Actions
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func displayResults(_ searchText: String) {
		if searchText.count < 3 {
			tableView.reloadData()
			return
		} else {
			// Clear the displayArray in case it's not empty
			displayArray.removeAll(keepingCapacity: true)
			self.activity.startAnimating()
//			self.tableView.beginUpdates()
//			async {
				let results = getSearchResults(searchText: searchText)
			// See WikipediaArticle.swift:71 for explanation
			//let results = getPreviewImages(articles: resultsPlain)
//			debugPrint(searchBarIsEmpty(), displayArray, results.count)
				for i in 0..<results.count {
					
					// TODO: Progress bar work
//					self.progress.setProgress((Float(i+1) / Float(results.count)), animated: true)
//					debugPrint("THIS IS THE PROGRESS \(self.progress.progress)")
					
					self.displayArray.insert(results[i], at: i)
				}
				self.tableView.reloadData()
				self.activity.stopAnimating()
//			}
//			self.tableView.endUpdates()
			debugPrint(displayArray)
			tableView.reloadData()
		}
	}
	
	func displayPage(url: URL) {
		
	}
	
	//private func present
	
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
	
	// MARK: Article Manipulation
	
	// MARK: Covert SVG's on the fly if we run into them
//	func pageImageFromSVG(svgURL: URL) -> UIImage {
//		let uiView = UIView(SVGURL: svgURL) { (svgLayer) in
//			svgLayer.resizeToFit(self.view.bounds)
//		}
//		let renderer = UIGraphicsImageRenderer()
//		let image = renderer.image { ctx in
//			uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
//		}
//		return image
//	}
}

extension MessagesViewController: UISearchResultsUpdating {
	// MARK: UISearchResultsUpdating
	func updateSearchResults(for searchController: UISearchController) {
		if !Reachability.isConnectedToNetwork() {
			self.displayArray.removeAll(keepingCapacity: true)
			self.tableView.reloadData()
			
			Whisper.show(shout: networkOfflineNotification, to: notificationViewController)
		} else {
			displayResults(searchController.searchBar.text!)
		}
	}
}

extension MessagesViewController: UISearchBarDelegate {
	// MARK: UISearchBarDelegate
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//		searchBar.resignFirstResponder()
		return true
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		self.tableView.reloadData()
		searchBar.resignFirstResponder()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.displayArray.removeAll(keepingCapacity: true)
		self.tableView.reloadData()
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		requestPresentationStyle(.expanded)
	}
}

