@preconcurrency import Messages

protocol MessageComposer: Sendable {
    @MainActor func insert(_ message: MSMessage) async throws
}

struct LiveMessageComposer: MessageComposer {
    // Apple: "Don't store a reference to the MSConversation parameter.
    // Always work with the activeConversation property, since the system
    // can update this between callbacks." We close over a provider that
    // reads activeConversation lazily on each insert.
    let conversationProvider: @MainActor () -> MSConversation?
    let requestCompactPresentation: @MainActor () -> Void

    @MainActor
    func insert(_ message: MSMessage) async throws {
        print("[WM] LiveMessageComposer.insert entered")
        guard let conversation = conversationProvider() else {
            print("[WM] LiveMessageComposer.insert: no active conversation, skipping")
            return
        }
        guard message.url != nil else {
            print("[WM] LiveMessageComposer.insert: nil url, skipping")
            return
        }
        print("[WM] LiveMessageComposer.insert: about to call conversation.insert")
        print("[WM]   localParticipantIdentifier=\(conversation.localParticipantIdentifier)")
        let request = requestCompactPresentation
        conversation.insert(message) { error in
            if let error {
                print("[WM] conversation.insert completion: ERROR \(error)")
            } else {
                print("[WM] conversation.insert completion: success")
            }
            // Dismiss only after iMessage finishes processing the inserted
            // message. Calling this synchronously after conversation.insert
            // races with the host's draft renderer and on iOS 26 leaves the
            // extension stuck in expanded mode, hiding the bubble.
            Task { @MainActor in
                request()
                print("[WM] conversation.insert completion: requested compact presentation")
            }
        }
        print("[WM] LiveMessageComposer.insert: conversation.insert returned")
    }
}
