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
    
    // Title labels
    @IBOutlet weak var topNavTitleLabel: UILabel!
    @IBOutlet weak var bottomNavTitleLabel: UILabel!
    @IBOutlet weak var defaultTitleLabel: UILabel!
    
    var chat:MumsnetChat?
    var messageSender = ChatMessageSender()
    var newMessageCheckTimer = NSTimer()
    
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
        

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)

        self.refreshData()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        self.newMessageCheckTimer.invalidate()

    }

    
    // MARK: - Setup
    
    /// Required setup
    private func setup() {
        
        if let user = UserManager.currentUser() {
            // Setup default username
            self.fromField.text = user.username
        }

        
        if let chat = self.chat {
         
            self.showNewMessageBar(show: false, animated: false)
            self.setupWithChat(chat)
        }
        else { // Show new chat
            
            self.showNewMessageBar(show: true, animated: false)
            self.setupNavTitles(nil)
            
            // Set completion for when first message is sent
            self.chatInputPresenter?.noChatCompletion = { (inputBar:ChatInputBar) -> Void in
                
                self.startNewChat(from: self.fromField.text, to: self.toField.text, message: inputBar.inputText)
            }
        }
    }
    
    private func setupWithChat(chat:MumsnetChat) {
        
        self.chat = chat
        self.messageSender.chat = chat
        self.dataSource = ChatDataSource(delegate: self, chat: chat)
        self.chatInputPresenter?.noChatCompletion = nil
        
        self.setupNavTitles(chat)

        // Start timer
        self.newMessageCheckTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ChatDetailViewController.refreshData), userInfo: nil, repeats: true)
        
        self.showNewMessageBar(show: false, animated: true)

    }
    
    
    func setupNavTitles(chat:MumsnetChat?) {
        
        if let chat = chat {
            // Show chat titles
            self.topNavTitleLabel.alpha = 1
            self.topNavTitleLabel.text = chat.otherUserUsernames.first ?? "Invalid Username"
            
            var bottomText = ""
            if let currentUsername = chat.currentUserUsername {
                bottomText = "Sending from: \(currentUsername)"
            }
            self.bottomNavTitleLabel.alpha = 1
            self.bottomNavTitleLabel.text = bottomText
            self.defaultTitleLabel.text = ""
            
        }
        else {
            self.topNavTitleLabel.alpha = 0
            self.bottomNavTitleLabel.alpha = 0
            self.defaultTitleLabel.text = "New Chat"
        }
    }
    
    func refreshData() {
        
        if let chat = self.chat {
            
            self.setPlaceholder("Loading messages...")
            APIManager.fetchChat(chatID: chat.objectID) { (result:ApiResult<MumsnetChat>) in
                switch result {
                    
                case ApiResult.Success(let chat):
                    self.setPlaceholder(nil)
                    self.dataSource?.setupWithChat(chat)
                    
                case ApiResult.Error(let errorResponse):
                    print(errorResponse.error)
                    self.setPlaceholder("Error loading messages!")

                }
            }
        }
    }
    
    // MARK: - Misc
    
    /**
     Show placeholder if there is no cells
     */
    func setPlaceholder(placeholder:String?) {
        
        if placeholder != nil && self.collectionView.numberOfItemsInSection(0) == 0 {

            self.collectionView.showPlaceholder(placeholder ?? "")
        }
        else {
            self.collectionView.hidePlaceholder()
        }
    }
    
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
                }, completion: { (completed) in
                    
                    if shouldShow {
                        delay(0.5, closure: {
                            self.toField.becomeFirstResponder()
                        })
                    }
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
            
                    self.setPlaceholder(nil)

                    switch result {
                    case ApiResult.Success(let chat):
                        
                        self.setupWithChat(chat)
                        self.refreshData()
//                        self.chat = chat
//                        self.showNewMessageBar(show: false, animated: true)
//                        self.dataSource?.setupWithChat(chat)
                        
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
        
        return [
            TextMessageModel.chatItemType: [
                TextMessagePresenterBuilder(
                    viewModelBuilder: TextMessageViewModelDefaultBuilder(),
                    interactionHandler: TextMessageHandler(baseHandler: self.baseMessageHandler)
                )
            ],
            SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()]
        ]
    }

}



