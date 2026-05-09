import Messages

protocol MessageComposer: Sendable {
    func insert(_ message: MSMessage) async throws
}

struct LiveMessageComposer: MessageComposer {
    private let conversation: MSConversation

    init(conversation: MSConversation) {
        self.conversation = conversation
    }

    func insert(_ message: MSMessage) async throws {
        guard message.url != nil else { return }
        await MainActor.run {
            conversation.insert(message, completionHandler: nil)
        }
    }
}
