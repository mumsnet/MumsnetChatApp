//
//  ChatListViewController.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 30/03/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import UIKit
import AudioToolbox


class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let pullToRefresh = UIRefreshControl()
    var newMessageCheckTimer = NSTimer()
    /// Chats stored temporarily that are faster to access
    var chats:[MumsnetChat] {
        
        get {
            return ChatCache.fetchOverviewChats()
        }
        set {
            ChatCache.setOverviewChats(newValue)
            
            self.tableView.reloadData()
            
            let placeholder: String? = self.chats.count == 0 ? "No chats yet." : nil
            self.showPlaceholder(placeholder)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Hack to use refreshcontrol
        self.pullToRefresh.addTarget(self, action: #selector(ChatListViewController.refreshTriggered), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.pullToRefresh)
        self.tableView.sendSubviewToBack(self.pullToRefresh)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        if let user = UserManager.currentUser() {
            // Logged in
            self.tableView.reloadData()
            self.refreshTriggered()
            self.title = user.username
        }
        else { // Logged out
            self.presentLogin(animated: false)
        }
        
        // Start timer
        self.newMessageCheckTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ChatListViewController.refreshTriggered), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)

        // Stop refresh
        self.newMessageCheckTimer.invalidate()
    }
    
    // MARK: - Misc
    
    func showPlaceholder(placeholder:String?) {
        
        if let placeholder = placeholder {
            self.tableView.showPlaceholder(placeholder)
        }
        else { // Hide
            self.tableView.hidePlaceholder()
        }
    }
    
    func presentLogin(animated isAnimated:Bool) {
        
        if let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            self.presentViewController(loginVC, animated: isAnimated, completion: nil)
        }
    }
    
    func refreshTriggered() {
        
        // Do not reload whilst the tableview is editing
        if !self.tableView.editing {
            
            // Reset all content
            self.reloadChats(pageToLoad: 1)
        }
    }
    
    func reloadChats(pageToLoad page:Int) {
        
        APIManager.fetchChats(page) { (result:ApiResult<[MumsnetChat]>) in

            self.pullToRefresh.endRefreshing()
            
            switch result {
                
            case ApiResult.Success(let chats):
                
//                if self.shouldVibrateWithNewUpdatedChats(chats) {
//                    self.playVibrate()
//                }
                self.chats = chats
                
            case ApiResult.Error(let errorResponse):
                print(errorResponse.error ?? "")
            }
        }
    }
    
    func deleteChat(chat:MumsnetChat) {
        
        APIManager.deleteChat(chat) { (result:ApiResult<Void>) in
            switch result {
                
            case ApiResult.Success(_):
                
                // Success, remove chat from datasource, then reload (to be sure)
                if let chatIndex = self.chats.indexOf(chat) {
                    self.chats.removeAtIndex(chatIndex)
                    self.tableView.reloadData()
                }
                self.refreshTriggered()
                
            case ApiResult.Error(let errorResponse):
                print(errorResponse.error)
            }
        }
    }
    
    func shouldVibrateWithNewUpdatedChats(chats:[MumsnetChat]) -> Bool {
        
        // If the first chat is unseen
        if let firstChat = self.chats.first {
            if firstChat.unreadMessages > 0 {
                
                // If the last message was < 5s ago
                if let postedAt = firstChat.lastMessage?.postedAt {
                    let secondsBefore = postedAt.secondsBeforeDate(NSDate())
                    if secondsBefore < 10 {
                        return true
                    }
                }
                
            }
        }

        return false
    }
    
    func playVibrate() {
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // MARK: - Actions
    
    @IBAction func switchUserButtonPressed(sender: UIButton) {
    
        self.presentLogin(animated: true)
    
    }
    
    @IBAction func newChatButtonPressed(sender: UIButton) {
    
        self.showChatVC(existingChat: nil)
    
    }
    
    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.chats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ChatListCell.cellID, forIndexPath: indexPath) as! ChatListCell
        
        let chat = self.chats[indexPath.row]
        cell.setupWithChat(chat)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let chat = self.chats[indexPath.row]
        self.showChatVC(existingChat: chat)
    }
    
    func showChatVC(existingChat chat:MumsnetChat?) {
        
        let chatDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatDetailViewController") as! ChatDetailViewController
        
        chatDetailVC.chat = chat
        
        self.navigationController?.pushViewController(chatDetailVC, animated: true)

    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // Ensure data source is correct
            if self.chats.count > indexPath.row {
                let chat = self.chats[indexPath.row]
                self.deleteChat(chat)
            }
            else {
                self.tableView.reloadData()
            }
        }
    }
}





