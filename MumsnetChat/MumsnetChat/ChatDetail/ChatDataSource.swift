//
//  ChatDataSource.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 30/03/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions


class ChatDataSource: ChatDataSourceProtocol {
    
    // Called whenever the data source is updated
    weak var delegate: ChatDataSourceDelegateProtocol?
    var slidingWindow: SlidingDataSource<ChatItemProtocol>
    var chat:MumsnetChat
    let preferredMaxWindowSize = 500


    lazy var messageSender: ChatMessageSender = {
        let sender = ChatMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        sender.chat = self.chat
        return sender
    }()
    
    init(delegate:ChatDataSourceDelegateProtocol, chat:MumsnetChat) {
        
        self.delegate = delegate
        self.chat = chat
        
        // Start with default of 0
        self.slidingWindow = SlidingDataSource(items: [], pageSize: APIManager.Constants.ChatPageDefaultSize)
        
        self.setChatMessages(chat)
        
//        self.slidingWindow = SlidingDataSource(items: messages, pageSize: APIManager.Constants.ChatPageDefaultSize)

    }
    
    // MARK: - Data Source Protocol
    
    var hasMoreNext: Bool {
        return self.slidingWindow.hasMore()
    }
    
    var hasMorePrevious: Bool {
        return self.slidingWindow.hasPrevious()
    }
    
    var chatItems: [ChatItemProtocol] {
        
        var chatItems:[ChatItemProtocol] = []
        
        chatItems = self.slidingWindow.itemsInWindow.map({$0 as ChatItemProtocol})
        
        return chatItems
    }
    
    
    func loadNext(completion: () -> Void) {
        print("Load Next Chat Page!")
        completion()
    }
    
    func loadPrevious(completion: () -> Void) {
        print("Load Previous Chat Page!")
        completion()
    }
    
    func adjustNumberOfMessages(preferredMaxCount preferredMaxCount: Int?, focusPosition: Double, completion: (didAdjust: Bool) -> Void) {
        
        let didAdjust = self.slidingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
        completion(didAdjust: didAdjust)
    }
    
    func addTextMessage(text: String) {
        
        let chatMessage = MumsnetChatMessage.createLocalMessage(text, isIncoming: false, senderUsername: self.chat.currentUserUsername ?? "")
        let uiMessage = TextMessageModel(messageModel: chatMessage, text: text)
        
        self.messageSender.sendMessage(uiMessage)
        self.slidingWindow.insertItem(uiMessage, position: .Bottom)
        self.delegate?.chatDataSourceDidUpdate(self)
        
    }
    
    
    /**
     Setup Chat UI with new Chat (if chat was not loaded in the beginning)
     */
    func setupWithChat(chat:MumsnetChat) {
        
        self.chat = chat
        
        self.setChatMessages(chat)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    func setChatMessages(chatWithMessages:MumsnetChat) {
        
        // Hack to fix objc bridging bug
        var messages = chatWithMessages.messages//.map({$0 as ChatItemProtocol})
        
        
        // If messages in chat, cache results 
        if chatWithMessages.messages.count > 0 {
            TalkCache.setDetailChat(chatWithMessages)
        }
        else {
            // If no unread messages AND no messages in chat show cached messages
            if chat.unreadMessages == 0 {
                if let chat = TalkCache.fetchChatWithID(chat.objectID) {
                    messages = chat.messages
                }
            }
        }
        
        // Create TextMessageModel from the base MumsnetChatMessage
        let portedMessages = messages.map({ (message:MumsnetChatMessage) -> TextMessageModel in
            
            let message =  TextMessageModel(messageModel: message, text: message.text ?? "")
            message.status = MessageStatus.Success
            return message
        })
        
        self.slidingWindow.setItems(portedMessages.map({$0 as ChatItemProtocol}))
    }
}

class ChatMessageSender {
    
    var chat:MumsnetChat?
    var onMessageChanged: ((message: MessageModelProtocol) -> Void)?
    
    func sendMessage(message:TextMessageModelProtocol) {
        
        if let chat = chat {
            self.updateMessage(message, status: MessageStatus.Sending)
            
            APIManager.sendChatMessage(message.text, chat: chat) { (result:ApiResult<MumsnetChat>) in
                
                switch result {
                    
                case ApiResult.Success(let chat):
                    
                    self.chat = chat
                    self.updateMessage(message, status: MessageStatus.Success)
                    
                case ApiResult.Error(let errorResponse):
                    print(errorResponse.error ?? "")
                    self.updateMessage(message, status: MessageStatus.Failed)
                    
                }
            }
        }
    }
    
    private func updateMessage(message: TextMessageModelProtocol, status: MessageStatus) {
        if message.status != status {
            message.status = status
            self.notifyMessageChanged(message)
        }
    }
    
    private func notifyMessageChanged(message: TextMessageModelProtocol) {
        self.onMessageChanged?(message: message)
    }
    
    
}

/**
 Extension to define the only type used
 */
extension TextMessageModel {
    static var chatItemType: ChatItemType {
        return "text"
    }
}

