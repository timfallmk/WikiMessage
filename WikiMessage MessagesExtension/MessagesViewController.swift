import Combine
import Messages
import SafariServices
import SwiftUI
import UIKit

final class MessagesViewController: MSMessagesAppViewController {

    private let appModel = AppModel()
    private let searchModel = SearchModel()
    private let searchBar = UISearchBar()
    private var hostingController: UIHostingController<AnyView>?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupHostingController()

        // Keep UISearchBar text in sync when query changes from SwiftUI (e.g. recent searches)
        searchModel.$query
            .receive(on: RunLoop.main)
            .sink { [weak self] query in
                if self?.searchBar.text != query {
                    self?.searchBar.text = query
                }
            }
            .store(in: &cancellables)
    }

    private func setupSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Wikipedia"
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupHostingController() {
        let root = RootView()
            .environmentObject(appModel)
            .environmentObject(searchModel)

        let hosting = UIHostingController(rootView: AnyView(root))
        hostingController = hosting

        addChild(hosting)
        // Without this, the hosting view forces a white background that ignores
        // the user's appearance setting.
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hosting.didMove(toParent: self)
    }

    override func willBecomeActive(with conversation: MSConversation) {
        appModel.composer = LiveMessageComposer(
            conversationProvider: { [weak self] in self?.activeConversation },
            requestCompactPresentation: { [weak self] in
                self?.requestPresentationStyle(.compact)
            }
        )

        if let url = conversation.selectedMessage?.url {
            appModel.selectedArticleURL = url
        }
    }

    override func didResignActive(with conversation: MSConversation) {
        appModel.composer = nil
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        DispatchQueue.main.async {
            self.appModel.presentationStyle = presentationStyle
        }
    }
}

extension MessagesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchModel.query = searchText
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if presentationStyle == .compact {
            requestPresentationStyle(.expanded)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
