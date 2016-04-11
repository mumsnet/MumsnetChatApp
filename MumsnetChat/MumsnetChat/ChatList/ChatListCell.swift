//
//  ChatListCell.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 30/03/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {
    
    static let cellID = "ChatListCell"
    
    @IBOutlet weak var fromToLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var newMessagesImageView: UIImageView!
    
    func setupWithChat(chat:MumsnetChat) {
        
        self.fromToLabel.text = "\(chat.currentUserUsername ?? "")  ->  \(chat.otherUserUsernames.first ?? "Invalid Username")"
        
        var dateText = ""
        if let message = chat.lastMessage {
            dateText = message.postedAt?.readableDateShort() ?? ""
        }
        self.dateLabel.text = dateText
        self.messageLabel.text = chat.lastMessage?.text ?? ""
        self.newMessagesImageView.hidden = chat.unreadMessages == 0
    }
}