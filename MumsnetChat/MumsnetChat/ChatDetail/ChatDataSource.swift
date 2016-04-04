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
    var slidingWindow: SlidingDataSource<ChatItemProtocol>!
    var chat:MumsnetChat
    let preferredMaxWindowSize = 500


//    var messages:[MumsnetChatMessage] = [] {
//        
//        didSet {
//            self.delegate?.chatDataSourceDidUpdate(self)
//        }
//    }
    lazy var messageSender: ChatMessageSender = {
        let sender = ChatMessageSender(chat: self.chat)
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()
    
    init(delegate:ChatDataSourceDelegateProtocol, chat:MumsnetChat, existingMessages:[ChatItemProtocol]) {
        
        self.delegate = delegate
        self.chat = chat
        self.slidingWindow = SlidingDataSource(items: existingMessages, pageSize: APIManager.Constants.ChatPageDefaultSize)

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
//        let uid = "\(self.nextMessageId)"
//        self.nextMessageId += 1
//        let message = createTextMessageModel(uid, text: text, isIncoming: false)
        
        let chatMessage = MumsnetChatMessage.createLocalMessage(text, isIncoming: false, senderUsername: self.chat.currentUserUsername ?? "")
        let uiMessage = TextMessageModel(messageModel: chatMessage, text: text)
        
        self.messageSender.sendMessage(uiMessage)
        self.slidingWindow.insertItem(uiMessage, position: .Bottom)
        self.delegate?.chatDataSourceDidUpdate(self)
        
    }
    
    // MARK: - Load Existing Messages
    
    func reloadData() {
        
        // TODO: show loading
        APIManager.fetchChat(chatID: chat.objectID) { (result:ApiResult<MumsnetChat>) in
            switch result {
                
            case ApiResult.Success(let chat):
                self.chat = chat
                
                let portedMessages = chat.messages.map({ (message:MumsnetChatMessage) -> TextMessageModel in
                    
                    let message =  TextMessageModel(messageModel: message, text: message.text ?? "")
                    message.status = MessageStatus.Success
                    return message
                })
                
                
                self.slidingWindow.setItems(portedMessages.map({$0 as ChatItemProtocol}))
                self.delegate?.chatDataSourceDidUpdate(self)
                
            case ApiResult.Error(let errorResponse):
                print(errorResponse.error)
            }
        }
    }
}

class ChatMessageSender {
    
    var chat:MumsnetChat
    var onMessageChanged: ((message: MessageModelProtocol) -> Void)?
    
    init(chat:MumsnetChat) {
        self.chat = chat
    }
    
    func sendMessage(message:TextMessageModelProtocol) {
        
        self.updateMessage(message, status: MessageStatus.Sending)

            APIManager.sendChatMessage(message.text, chat: self.chat) { (result:ApiResult<MumsnetChat>) in
                
                switch result {
                    
                case ApiResult.Success(let chat):
                    
                    self.chat = chat
                    self.updateMessage(message, status: MessageStatus.Success)
//                    
//                    if let message = chat.lastMessage {
//                        self.slidingWindow.insertItem(message, position: .Bottom)
//                        self.delegate?.chatDataSourceDidUpdate(self)
//                    }
                    
                case ApiResult.Error(let errorResponse):
                    print(errorResponse.error ?? "")
                    self.updateMessage(message, status: MessageStatus.Failed)
                    
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
