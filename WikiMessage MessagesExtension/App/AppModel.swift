import Combine
import Messages

final class AppModel: ObservableObject {
    @Published var presentationStyle: MSMessagesAppPresentationStyle = .compact
    @Published var composer: (any MessageComposer)?
    @Published var selectedArticleURL: URL?
}
