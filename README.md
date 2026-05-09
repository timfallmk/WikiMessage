# WikiMessage

An iMessage extension for searching and sharing Wikipedia articles.

## What it does

Open WikiMessage from the iMessage app drawer, type a query, and tap a result to insert a richly formatted article card into the conversation. Recipients can tap the card to open the article in Safari Reader Mode without leaving Messages.

## Requirements

- Xcode 17 or later
- iOS 17.0+ deployment target
- Apple Developer account (team `T5VJ9JRCNB`) for signing

## Building

```bash
open WikiMessage.xcodeproj
```

Select the **WikiMessage MessagesExtension** scheme, choose an iOS 17+ simulator, and run. No package fetching or Carthage bootstrap needed — zero third-party dependencies.

To run tests:

```bash
xcodebuild \
  -project WikiMessage.xcodeproj \
  -scheme "WikiMessage MessagesExtension" \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
  test \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

## Architecture

```
WikiMessage MessagesExtension/
├── MessagesViewController.swift   # Thin UIHostingController shell
├── App/
│   ├── AppModel.swift             # @Observable: presentation style, composer, selected URL
│   └── RootView.swift             # NavigationStack + .searchable entry point
├── Features/
│   ├── Search/
│   │   ├── SearchModel.swift      # @Observable: query, phase, recent searches
│   │   ├── SearchResultsList.swift
│   │   ├── ArticleRow.swift
│   │   └── RecentSearchesStore.swift
│   ├── States/
│   │   ├── LoadingView.swift
│   │   ├── EmptyResultsView.swift
│   │   └── ErrorView.swift
│   └── SafariView.swift           # UIViewControllerRepresentable
├── Messaging/
│   ├── MessageComposer.swift      # Protocol + LiveMessageComposer
│   └── MessageBuilder.swift      # MSMessageTemplateLayout builder
├── Data/
│   ├── Article.swift              # Domain model (Sendable, Identifiable, Hashable)
│   ├── WikipediaService.swift     # actor; search + summary
│   └── DTOs/
│       ├── SummaryDTO.swift       # /api/rest_v1/page/summary shape
│       └── SearchResponseDTO.swift # Wikimedia Core API search shape
└── Networking/
    ├── HTTPClient.swift           # actor; URLSession wrapper with shared decoder
    └── NetworkMonitor.swift       # @Observable NWPathMonitor wrapper

WikiMessageExtensionTests/
├── Support/MockURLProtocol.swift
├── Fixtures/{summary_einstein,search_swift}.json
├── DTOs/{SummaryDTO,SearchResponseDTO}Tests.swift
├── Services/WikipediaServiceTests.swift
└── Messaging/MessageBuilderTests.swift
```

## APIs used

| Purpose | Endpoint |
|---|---|
| Search | `https://api.wikimedia.org/core/v1/wikipedia/en/search/page?q=…&limit=10` |
| Article summary | `https://en.wikipedia.org/api/rest_v1/page/summary/{title}` |

The language path segment (`/en/`) is parameterised in `WikipediaService` for future multi-language support.

## Original version

The pre-modernization state (Swift 4 / iOS 11 / Carthage / UIKit, last commit 2018-10-10) is preserved at tag `v1.0-legacy`.
