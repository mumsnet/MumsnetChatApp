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
    
    func setupWithChat(chat:MumsnetChat) {
        
        self.fromToLabel.text = "\(chat.currentUserUsername ?? "")  ->  \(chat.otherUserUsernames.first ?? "")"
        
        var dateText = ""
        if let message = chat.lastMessage {
            dateText = NSDateFormatter.mmHHddMMStringFromDate(dateToConvert: message.postedAt) ?? ""
        }
        self.dateLabel.text = dateText
        self.messageLabel.text = chat.lastMessage?.text ?? ""
        
    }
}