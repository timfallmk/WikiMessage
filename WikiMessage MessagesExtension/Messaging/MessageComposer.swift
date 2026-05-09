@preconcurrency import Messages

protocol MessageComposer: Sendable {
    @MainActor func insert(_ message: MSMessage) async throws
}

struct LiveMessageComposer: MessageComposer {
    private let conversation: MSConversation

    init(conversation: MSConversation) {
        self.conversation = conversation
    }

    @MainActor
    func insert(_ message: MSMessage) async throws {
        print("[WM] LiveMessageComposer.insert entered")
        guard message.url != nil else {
            print("[WM] LiveMessageComposer.insert: nil url, skipping")
            return
        }
        print("[WM] LiveMessageComposer.insert: about to call conversation.insert")
        print("[WM]   localParticipantIdentifier=\(conversation.localParticipantIdentifier)")
        conversation.insert(message) { error in
            if let error {
                print("[WM] conversation.insert completion: ERROR \(error)")
            } else {
                print("[WM] conversation.insert completion: success")
            }
        }
        print("[WM] LiveMessageComposer.insert: conversation.insert returned")
    }
}
