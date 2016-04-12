//
//  MumsnetChatMessage.swift
//  Talk
//
//  Created by Tim Windsor Brown on 24/03/2016.
//  Copyright © 2016 Mumsnet. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

class MumsnetChatMessage: MumsnetModelObject, MessageModelProtocol  {
    
//    enum MessageType: ChatItemType {
//        case Text = "text"
//    }
    
    var senderUsername:String?
    var isMe: Bool = false
    var postedAt: NSDate?
    let type: ChatItemType = TextMessageModel.chatItemType
    
    var uid: String {
        return String(objectID)
    }
    
    // MARK: TextMessageModelProtocol
    var text:String?

    // MARK: MessageModelProtocol
    var senderId: String {
        return senderUsername ?? ""
    }
    var isIncoming: Bool {
        return !self.isMe
    }
    var date: NSDate {
        return self.postedAt!
    }
    var status: MessageStatus = MessageStatus.Sending // Default
    
    
    // MARK: - Message Handling
    
    // Local creation, for when sending the message
    static func createLocalMessage(message:String, isIncoming:Bool, senderUsername:String) -> MumsnetChatMessage {
     
        let randomID = Int(arc4random_uniform(100000))
        let localMessage = MumsnetChatMessage(objectID: randomID)
        localMessage.postedAt = NSDate()
        localMessage.isMe = !isIncoming
        localMessage.senderUsername = senderUsername
        return localMessage
    }
    
    static func chatMessageFromDictionary(dictionary:AnyObject?) -> MumsnetChatMessage? {
        
        if let rawMessage = dictionary as? [String:AnyObject] {
            
            let chatMessage = MumsnetChatMessage(objectID: rawMessage[MumsnetJSONDataKey.IDKey] as? Int ?? 0)
            chatMessage.text = rawMessage[MumsnetJSONDataKey.ChatMessageKey] as? String
            chatMessage.senderUsername = rawMessage[MumsnetJSONDataKey.ChatSenderKey] as? String
            chatMessage.isMe = rawMessage[MumsnetJSONDataKey.ChatIsMeKey] as? Bool ?? false
            if let dateString = rawMessage[MumsnetJSONDataKey.ChatPostedAtKey] as? String {
                chatMessage.postedAt = NSDateFormatter.dateFromISO8601String(dateString: dateString)
            }
            
            return chatMessage
        }
        return nil
    }
    
    override var description: String {
        return "\nID: \(self.objectID)  |  sender: \(self.senderUsername ?? "??")  |  Me: \(self.isMe)  |  \"\(self.text ?? "N/A")\"  "
    }
}