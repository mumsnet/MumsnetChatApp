


import Foundation

/**
 Mumsnet Chat Cache, storing chats in NSUserDefaults, so they will be persisted after logging out.
 */
class ChatCache {
    
    /// Shared instance, for easy access
    static var sharedCache = ChatCache() {
        
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatCache.loggedOutCalled(_:)), name: MumsnetNotification.LoggedOutNotification, object: nil)
        }
    }
    
    // Chats listed in the chat overview
    var overviewChats: [MumsnetChat] = []
    
    // Chats listed in the chat overview
    var detailChats: [MumsnetChat] = []
    
    
    @objc private func loggedOutCalled(notification: NSNotification) {
        
        self.clearChatCache()
    }
    
    /**
     Clear all chat-related cached data. To be used when logging out.
     */
    private func clearChatCache() {
        
        objc_sync_enter(self)
        
        // Chats
        ChatCache.sharedCache.overviewChats = []
        ChatCache.sharedCache.detailChats = []
        
        objc_sync_enter(self)
    }
    
    
    /**
     Set cached overview chats.
     
     - parameter chats: Array of chats to cache
     */
    static func setOverviewChats(chats:[MumsnetChat]) {
        objc_sync_enter(self)
        ChatCache.sharedCache.overviewChats = chats
        objc_sync_exit(self)
    }
    
    /**
     fetch cached overview chats.
     
     - return Array of chats from cache, empty if the cache is empty
     */
    static func fetchOverviewChats() -> [MumsnetChat] {
        
        return ChatCache.sharedCache.overviewChats
    }
    
    /**
     Set cached full chats with messages
     
     - parameter chats: Array of chats to cache
     */
    static func setDetailChat(chat:MumsnetChat) {
        
        objc_sync_enter(self)
        if let cachedChat = ChatCache.sharedCache.detailChats.filter({ $0.objectID == chat.objectID }).first,
            let index = ChatCache.sharedCache.detailChats.indexOf(cachedChat) {
            // Already exists
            ChatCache.sharedCache.detailChats[index] = chat
        }
        else { // Does not yet exist
            ChatCache.sharedCache.detailChats.append(chat)
        }
        objc_sync_exit(self)
    }
    
    /**
     Fetch cached chat with ID
     
     - parameter chatID: ID of chat required
     - return Chat from cache with ID, nil if it doesn't exist
     */
    static func fetchChatWithID(chatID:Int) -> MumsnetChat? {
        
        if let cachedChat = ChatCache.sharedCache.detailChats.filter({ $0.objectID == chatID }).first {
            return cachedChat
        }
        return nil
    }
    
}

