//
//  UserActionHandler.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 30/03/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

class TextMessageHandler: BaseMessageInteractionHandlerProtocol {
    private let baseHandler: BaseMessageHandler
    init (baseHandler: BaseMessageHandler) {
        self.baseHandler = baseHandler
    }
    func userDidTapOnFailIcon(viewModel viewModel: TextMessageViewModel) {
        self.baseHandler.userDidTapOnFailIcon(viewModel: viewModel)
    }
    
    func userDidTapOnBubble(viewModel viewModel: TextMessageViewModel) {
        self.baseHandler.userDidTapOnBubble(viewModel: viewModel)
    }
    
    func userDidLongPressOnBubble(viewModel viewModel: TextMessageViewModel) {
        self.baseHandler.userDidLongPressOnBubble(viewModel: viewModel)
    }
}

// Not handling photo messages
/**
class PhotoMessageHandler: BaseMessageInteractionHandlerProtocol {
    private let baseHandler: BaseMessageHandler
    init (baseHandler: BaseMessageHandler) {
        self.baseHandler = baseHandler
    }
    
    func userDidTapOnFailIcon(viewModel viewModel: PhotoMessageViewModel) {
        self.baseHandler.userDidTapOnFailIcon(viewModel: viewModel)
    }
    
    func userDidTapOnBubble(viewModel viewModel: PhotoMessageViewModel) {
        self.baseHandler.userDidTapOnBubble(viewModel: viewModel)
    }
    
    func userDidLongPressOnBubble(viewModel viewModel: PhotoMessageViewModel) {
        self.baseHandler.userDidLongPressOnBubble(viewModel: viewModel)
    }
}
*/


class BaseMessageHandler {
    
    private let messageSender: ChatMessageSender
    init (messageSender: ChatMessageSender) {
        self.messageSender = messageSender
    }
    func userDidTapOnFailIcon(viewModel viewModel: MessageViewModelProtocol) {
        NSLog("userDidTapOnFailIcon")
//        self.messageSender.sendMessage(viewModel.messageModel)
    }
    
    func userDidTapOnBubble(viewModel viewModel: MessageViewModelProtocol) {
        NSLog("userDidTapOnBubble")
        
    }
    
    func userDidLongPressOnBubble(viewModel viewModel: MessageViewModelProtocol) {
        NSLog("userDidLongPressOnBubble")
    }
}