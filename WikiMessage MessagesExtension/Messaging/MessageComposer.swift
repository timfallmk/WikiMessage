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
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            conversation.insert(message) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
