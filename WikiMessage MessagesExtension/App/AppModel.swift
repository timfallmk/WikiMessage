import Messages
import Observation

@Observable
@MainActor
final class AppModel {
    var presentationStyle: MSMessagesAppPresentationStyle = .compact
    var composer: (any MessageComposer)?
    var selectedArticleURL: URL?
}
