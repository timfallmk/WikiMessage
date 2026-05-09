import Messages
import SafariServices
import SwiftUI
import UIKit

final class MessagesViewController: MSMessagesAppViewController {

    private let appModel = AppModel()
    private var hostingController: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let root = RootView()
            .environment(appModel)

        let hosting = UIHostingController(rootView: AnyView(root))
        hostingController = hosting

        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hosting.didMove(toParent: self)
    }

    override func willBecomeActive(with conversation: MSConversation) {
        appModel.composer = LiveMessageComposer(conversation: conversation)

        if let url = conversation.selectedMessage?.url {
            appModel.selectedArticleURL = url
        }
    }

    override func didResignActive(with conversation: MSConversation) {
        appModel.composer = nil
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        Task { @MainActor in
            appModel.presentationStyle = presentationStyle
        }
    }
}
