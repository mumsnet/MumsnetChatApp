//
//  ChatDetailViewController.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 30/03/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class ChatDetailViewController: ChatViewController {
    
    
    var chat:MumsnetChat!
    var messageSender: ChatMessageSender!

    
    lazy private var baseMessageHandler: BaseMessageHandler = {
        return BaseMessageHandler(messageSender: self.messageSender)
    }()
    
    var dataSource: ChatDataSource! {
        didSet {
            self.chatDataSource = self.dataSource
        }
    }
    
    var chatInputPresenter: ChatInputBarPresenter!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        super.chatItemsDecorator = ChatItemsDemoDecorator()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.dataSource.reloadData()

    }
    
    // MARK: - Setup
    
    /// Required setup
    func setup(chat:MumsnetChat) {
        
        self.chat = chat
        self.messageSender = ChatMessageSender(chat: chat)
        self.dataSource = ChatDataSource(delegate: self, chat: chat)
    }
    
    override func createChatInputView() -> UIView {
        let chatInputView = ChatInputBar.loadNib()
        self.configureChatInputBar(chatInputView)
        self.chatInputPresenter = ChatInputBarPresenter(chatInputView: chatInputView, chatInputItems: self.createChatInputItems())
        return chatInputView
    }
    
    func configureChatInputBar(chatInputBar: ChatInputBar) {
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonTitle = NSLocalizedString("Send", comment: "")
        appearance.textPlaceholder = NSLocalizedString("Type a message", comment: "")
        chatInputBar.setAppearance(appearance)
    }
    
    func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
//        items.append(self.createPhotoInputItem())
        return items
    }
    
    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in
            self?.dataSource.addTextMessage(text)
        }
        return item
    }
    
//    private func createPhotoInputItem() -> PhotosChatInputItem {
//        let item = PhotosChatInputItem(presentingController: self)
//        item.photoInputHandler = { [weak self] image in
//            self?.dataSource.addPhotoMessage(image)
//        }
//        return item
//    }

    
    // MARK: - Override ChatViewController Methods
    
    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        
        let builder = TextMessageViewModelDefaultBuilder()
        let interactionHandler = TextMessageHandler(baseHandler: self.baseMessageHandler)

        return [
            MumsnetChatMessage.MessageType.Text.rawValue: [
                TextMessagePresenterBuilder(
                    viewModelBuilder: builder,
                    interactionHandler: interactionHandler
                )
            ],
            SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()]
            
        ]
    }
    
//    // MARK: - ChatDataSourceDelegateProtocol
//    
//    override func chatDataSourceDidUpdate(chatDataSource: ChatDataSourceProtocol) {
//        
//        
//    }
}

