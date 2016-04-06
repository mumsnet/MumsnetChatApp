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
    
    @IBOutlet weak var newUserBarY: NSLayoutConstraint!
    @IBOutlet weak var newUserBar: UIView!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    
    var chat:MumsnetChat? {
        didSet {
            if let chat = chat {
                self.messageSender.chat = chat
                self.dataSource = ChatDataSource(delegate: self, chat: chat, existingMessages: chat.messages)
                
                self.chatInputPresenter?.noChatCompletion = nil
            }
        }
    }
    var messageSender = ChatMessageSender()
    
    lazy private var baseMessageHandler: BaseMessageHandler = {
            return BaseMessageHandler(messageSender: self.messageSender)
    }()
    
    var dataSource: ChatDataSource? {
        didSet {
            self.chatDataSource = self.dataSource
        }
    }
    
    var chatInputPresenter: ChatInputBarPresenter?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        super.chatItemsDecorator = ChatItemsDemoDecorator()
        self.setup()

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.dataSource?.refreshData()

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)

    }
    
    // MARK: - Setup
    
    /// Required setup
    private func setup() {
        
        if let user = UserManager.currentUser() {
            // Setup default username
            self.fromField.text = user.username
        }
        
        if self.chat == nil { // Show new chat
            // Set completion for when first message is sent
            self.chatInputPresenter?.noChatCompletion = { (inputBar:ChatInputBar) -> Void in
                
                self.startNewChat(from: self.fromField.text, to: self.toField.text, message: inputBar.inputText)
            }
        }
        
        let showNewMessage = (self.chat == nil)
        self.showNewMessageBar(show: showNewMessage, animated: false)
    }
    
    // MARK: - Misc
    
    func showNewMessageBar(show shouldShow:Bool, animated:Bool) {
        
        let duration = animated ? 0.5 : 0
        let navHeight = (self.navigationController?.navigationBar.frame.height ?? 0) + 20
        let newY = shouldShow ? navHeight : -(self.newUserBar.frame.height + navHeight)
        
        if self.newUserBarY.constant != newY {
            self.newUserBarY.constant = newY
            self.view.setNeedsUpdateConstraints()

            self.newUserBar.superview?.bringSubviewToFront(self.newUserBar)
            
            UIView.animateWithDuration(duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    /**
     New chat started
     */
    func startNewChat(from fromUser:String?, to:String?, message:String?) {
        
        if let toUser = to, let fromUser = fromUser {
            if let message = message {
                APIManager.startChat([fromUser, toUser], message: message, completion: { (result:ApiResult<MumsnetChat>) in
            
                    switch result {
                        
                    case ApiResult.Success(let chat):
                        self.chat = chat
                        self.showNewMessageBar(show: false, animated: true)
                        self.dataSource?.setupWithChat(chat)
                        
                    case ApiResult.Error(let errorResponse):
                        print(errorResponse.error)
                        // Show Error
                    }
        })
            }
            else { // No message
                // Show error
            }
        }
        else { // No to user
            // Show error
        }
    }
    
    // MARK: - Chatto Protocols
    
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
            self?.dataSource?.addTextMessage(text)
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

