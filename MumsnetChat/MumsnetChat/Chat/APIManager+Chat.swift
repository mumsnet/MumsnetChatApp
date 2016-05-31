//
//  APIManager.swift
//  Talk
//
//  Created by Tim Windsor Brown on 08/03/2016.
//  Copyright © 2016 Mumsnet. All rights reserved.
//

/**
    API MANAGER

    The APIManager handles all APIs using AlamoFire. It's a convenient way to track 
    all endpoints, and keeps consistency throughout the app.
*/

import Foundation
import Alamofire


// MARK: - Chat API Calls
extension APIManager {

    
    /**
     Fetch full chat object
     
     - parameter chatID: ID of the chat to fetch
     - parameter completion: ApiResult object with chat if successful
     */
    static func fetchChat(chatID chatID:Int, completion:(ApiResult<MumsnetChat>) -> ()) {
        
        let urlString = MumsnetAPIEndPoint.FetchChatsEndPoint + "/\(chatID)"
        let parameters:[String:AnyObject] = [:]
//        parameters[MumsnetAPIParameter.ChatOrderParameter] = MumsnetAPIParameter.ChatOrderDescendingParameter
        
        manager.request(.GET, urlString, parameters: parameters, headers: authHeaders()).JSONHandler(completion) { (data) -> MumsnetChat? in
            
            if let rawChat = data as? [String: AnyObject] {
                if let chat = MumsnetChat.chatFromDictionary(rawChat) {
                    return chat
                }
            }
            
            return nil
        }
    }
    
    /**
     Fetch paged list of all chats
     
     - parameter page: Page to load
     - parameter completion: ApiResult object with chats if successful
     */
    static func fetchChats(page:Int, completion:(ApiResult<[MumsnetChat]>) -> ()) {
        
        let urlString = MumsnetAPIEndPoint.FetchChatsEndPoint
        
        var parameters:[String:AnyObject] = [:]
        parameters[MumsnetAPIParameter.PageParameter] = page
        parameters[MumsnetAPIParameter.PerParameter] = APIManager.Constants.ChatPageDefaultSize
        
        manager.request(.GET, urlString, parameters: parameters, headers: authHeaders()).JSONHandler(completion) { (data) -> [MumsnetChat]? in
            
            var chats:[MumsnetChat] = []
            
            if let data = data as? [String: AnyObject],
            let rawChats = data[MumsnetJSONDataKey.ChatsKey] as? [[String: AnyObject]] {
                
                for rawChat in rawChats {
                    if let chat = MumsnetChat.chatFromDictionary(rawChat) {
                        chats.append(chat)
                    }
                }
            }
            
            // Arrange in date order (API should do this)
            chats = chats.sort({ (firstChat, secondChat) -> Bool in
                
                if let firstDate = firstChat.lastMessage?.postedAt,
                    let secondDate = secondChat.lastMessage?.postedAt {
                    return firstDate.isLaterThanDate(secondDate)
                }
                return false
            })
            
            return chats
        }
    }
    
    /**
     Begin chat with the listed usernames and an initial message
     
     - parameter receiverUsernames: array of usernames to add to chat
     - parameter message: Initial message to begin chat with
     - parameter completion: ApiResult object with new chat if successful
     */
    static func startChat(fromUsername fromUser:String, receiverUsernames:[String], message:String, completion:(ApiResult<MumsnetChat>) -> ()) {
        
        let urlString = MumsnetAPIEndPoint.StartChatEndPoint
        
        var parameters:[String:AnyObject] = [:]
        
        parameters[MumsnetAPIParameter.ChatSendingUsername] = fromUser
        parameters[MumsnetAPIParameter.ChatParticipantsParameter] = receiverUsernames
        parameters[MumsnetAPIParameter.ChatMessageParameter] = message
        
        manager.request(.POST, urlString, parameters: parameters, headers: authHeaders()).JSONHandler(completion) { (data) -> MumsnetChat? in
            
            if let rawChat = data as? [String: AnyObject] {
                if let chat = MumsnetChat.chatFromDictionary(rawChat) {
                    return chat
                }
            }
            
            return nil
        }
    }
    
    /**
     Send a new message to the chat
     
     - parameter newMessage: New message to send to the chat
     - parameter chat: Existing chat object to send the message to
     - parameter completion: ApiResult completion, with the updated chat if successful
     */
    static func sendChatMessage(newMessage:String, chat:MumsnetChat, completion:(ApiResult<MumsnetChat>) -> ()) {
        
        let urlString = MumsnetAPIEndPoint.SendChatMessageEndPoint
        
        var parameters:[String:AnyObject] = [:]
        parameters[MumsnetAPIParameter.ChatIDParameter] = chat.objectID
        parameters[MumsnetAPIParameter.ChatMessageParameter] = newMessage
        
        manager.request(.POST, urlString, parameters: parameters, headers: authHeaders()).JSONHandler(completion) { (data) -> MumsnetChat? in
            
            if let rawChat = data as? [String: AnyObject] {
                if let chat = MumsnetChat.chatFromDictionary(rawChat) {
                    return chat
                }
            }
            
            return nil
        }
    }
    
    /**
     Delete chat
     
     - parameter chat: Chat to delete
     - parameter completion: ApiResult object
     */
    static func deleteChat(chat:MumsnetChat, completion:(ApiResult<Void>) -> ()) {
        
        let urlString = MumsnetAPIEndPoint.DeleteChatEndPoint + "/\(chat.objectID)"
        
        manager.request(.DELETE, urlString, parameters: [:], headers: authHeaders()).JSONHandler(completion)
    }
    
    /**
     Delete Chat message
     
     - parameter message: Message to delete
     - parameter completion: ApiResult object
     */
    static func deleteMessage(message:MumsnetChatMessage, completion:(ApiResult<Void>) -> ()) {
        
        let urlString = MumsnetAPIEndPoint.DeleteChatMessageEndPoint + "/\(message.objectID)"
        
        manager.request(.DELETE, urlString, parameters: [:], headers: authHeaders()).JSONHandler(completion)
    }
    
    /**
     Block a user from sending messages to the receivee via chat.
     
     The blocked user will be able to send messages successfully, but the messages will not be forwarded to the receivee.
     
     - parameter username: The username to block
     - parameter completion: ApiResult object
     */
    static func blockUserFromChat(username:String, completion:(ApiResult<Void>) -> ()) {
        
        let urlString = MumsnetAPIEndPoint.BlockChatUserEndPoint
        var parameters:[String:AnyObject] = [:]
        parameters[MumsnetAPIParameter.UsernameParameter] = username

        manager.request(.POST, urlString, parameters: parameters, headers: authHeaders()).JSONHandler(completion)
    }
}
