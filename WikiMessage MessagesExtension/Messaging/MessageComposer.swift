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
        conversation.insert(message) { error in
            if let error {
                print("[WM] conversation.insert completion: ERROR \(error)")
            } else {
                print("[WM] conversation.insert completion: success")
            }
        }
        print("[WM] LiveMessageComposer.insert: conversation.insert returned")
        // Apple's iMessage sample apps (IceCreamBuilder etc.) consistently
        // request compact presentation right after insert. Without this,
        // iMessage's draft renderer may compose into a still-expanded
        // extension and crash inside CKComposition.
        requestCompactPresentation()
        print("[WM] LiveMessageComposer.insert: requested compact presentation")
    }
}
