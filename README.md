# Wikipedia Message

### An iMessages extension for searching, sending, and reading article from Wikipedia

---

## Purpose

Wikipedia Message (WikiMessage) is a [MessagesExtension](messages-extension) for Messages in iOS. It allows the user to quickly search for articles on Wikipedia and add them to a conversation. Selected articles are richly formatted in a custom message layout. Receivers can open the linked articles inline from Messages and view a stripped down reader mode of the contents, or choose to view the fully rendered version without leaving Messages. Rich formatting also appears on non-iOS devices (i.e. macOS) and allow the article to open directly inside a browser.

All of that aside, it was mostly a way for me to explore the current state of Swift and discover what a nightmare mobile development is.

## Design

WikiMessage is a [standalone](standalone) Messages App and thus does not come with a "container" (host) application. As such, it's feature set is limited to the [`MessagesExtension`](messages-extension) API subset. While an extension with a container app would be able to do processing within the host application, app processing for a standalone extension is done within the extension code itself.

Luckily WikiMessage's function is simple and straightforward. The basic functionality is as follows:

- Send flow:
  1. Open a search interface for searching Wikipedia
  2. Perform real-time fuzzy (more on this later) searches based on user input
  3. Return list of relevant results
  4. Allow user to select specific article
  5. Preview selected article for sending
  6. Send article

- Receive flow:
  1. Receive richly formatted message of sent article in conversation
  2. Select article to open in-line preview
  3. Browse and read full contents of selected article and provide limited browsing within the rendered interface
  4. Show fully rendered article page upon request
  5. Allow opening in other applications
   (non-iOS) Allow opening of article in default browser

In addition to this basic functionality, the interface should provide additional amounts of information (preview images, subtitles, description text, etc.), at the appropriate steps, so that the user doesn't have to go to another application to find an intended article.

### Wikipedia API

At the heart of WikiMessages is the [Wikipedia API](https://www.mediawiki.org/wiki/API:Main_page), provided by the WikiMedia Foundation. Wikipedia offers a number of different API's to access content. WikiMessages make use of the RESTful API.

**Note**: Although multiple "top level" language Wikipedia's provide a RESTful API, WikiMessages current only uses the API for the English Wikipedia page at [https://en.wikipedia.org/](wikipedia). Multi-language support may be considered in the future.

The mechanics of RESTful APIs will not be dealt with here. Familiarity with these types of APIs and how to query them is assumed.

Wikipedia provides a very useful [sandbox](https://www.mediawiki.org/wiki/Special:ApiSandbox) for testing queries against real data. It is recommended to try any new queries here.

### Step 1: Searching

The primary query to the Wikipedia API is to perform a text based search against article titles based on a given string. This search should return the full list of relevant (more on that later) articles as well as some light metadata on each.

When a user first inputs a search string into the search box, a query is constructed of [url-encoded] elements and sent to the Wikipedia API.

**Components**:

Entering text in the search bar triggers a query to the `action` endpoint of the API. The `searchForArticle` method constructs a basic query using the `action=query` method.
