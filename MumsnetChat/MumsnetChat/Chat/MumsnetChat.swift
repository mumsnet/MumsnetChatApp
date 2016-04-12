//
//  Chat.swift
//  JSQMessages
//
//  Created by Tim Windsor Brown on 21/01/2016.
//  Copyright © 2016 Hexed Bits. All rights reserved.
//

import Foundation


/**
 {
 "chat": {
 "id": 9,
 "last_message": "test message",
 "last_message_username": "updatedUsernameYo",
 "last_message_added_at": "2016-03-24T17:28:55+00:00",
 "current_user_username": "updatedUsernameYo",
 "unread_messages": 0,
 "other_users": [
 "mumsnetguestposts"
 ],
 "total_messages": 1,
 "page": 1,
 "per": 20,
 "order": "DESC",
 "messages": [
 {
 "id": 9,
 "message": "test message",
 "sender_username": "updatedUsernameYo",
 "is_me": 1,
 "posted_at": "2016-03-24T17:28:55+00:00"
 }
 ]
 }
 }
*/

import Chatto

class MumsnetChat: MumsnetModelObject {

    var lastMessage:MumsnetChatMessage?
    var currentUserUsername:String?
    var otherUserUsernames:[String] = []
    var unreadMessages = 0
    var totalMessages = 0
    var messages:[MumsnetChatMessage] = []
 
    
    
    static func chatFromDictionary(dictionary:[String:AnyObject]) -> MumsnetChat? {
        
        if let rawChat = dictionary["chat"] as? [String:AnyObject] {
            
            let chat = MumsnetChat(objectID: rawChat[MumsnetJSONDataKey.IDKey] as? Int ?? 0)
            
            chat.lastMessage = MumsnetChatMessage.chatMessageFromDictionary(rawChat[MumsnetJSONDataKey.ChatLastMessageKey])
            
            chat.currentUserUsername = rawChat[MumsnetJSONDataKey.ChatCurrentUsernameKey] as? String
            chat.otherUserUsernames = rawChat[MumsnetJSONDataKey.ChatOtherUsersKey] as? [String] ?? []
            chat.totalMessages = rawChat[MumsnetJSONDataKey.ChatTotalMessagesKey] as? Int ?? 0
            chat.unreadMessages = rawChat[MumsnetJSONDataKey.ChatUnreadMessagesKey] as? Int ?? 0
            
            if let rawMessages = rawChat[MumsnetJSONDataKey.ChatMessagesKey] as? [[String:AnyObject]] {
                for rawMessage in rawMessages {
                    if let message = MumsnetChatMessage.chatMessageFromDictionary(rawMessage) {
                        chat.messages.append(message)
                    }
                }
                
                // Order chats by date
                chat.messages.sortInPlace({ (message0:MumsnetChatMessage, message1:MumsnetChatMessage) -> Bool in
                    
                    if let date0 = message0.postedAt,
                        let date1 = message1.postedAt {
                        return date0.timeIntervalSince1970 < date1.timeIntervalSince1970
                    }
                    return false
                })
            }
            
//            // API HACK: If empty messages, load the 'last message'
//            if chat.messages.count == 0 {
//                if let lastMessage = chat.lastMessage {
//                    chat.messages = [lastMessage]
//                }
//            }
            
            return chat

        }
        return nil
    }
    
    
    override var description: String {
        return "\nID: \(self.objectID)  |  My username: \(self.currentUserUsername ?? "??")  |  Other Users: \(self.otherUserUsernames)  |  Unread: \(self.unreadMessages)  |  Total: \(self.totalMessages)\n\"\(self.messages)\""
    }

}







