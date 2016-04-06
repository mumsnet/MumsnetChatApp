//
//  ChatListViewController.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 30/03/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let pullToRefresh = UIRefreshControl()
    var chats:[MumsnetChat] = [] {
        
        didSet {
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
        
        
        if UserManager.currentUser() == nil {
            self.presentLogin(animated: false)
//            self.view.alpha = 0
        }
        else {
            self.reloadChats(pageToLoad: 1)
//            self.view.alpha = 1
        }
        
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
        
        // Reset all content
        self.reloadChats(pageToLoad: 1)
    }
    
    func reloadChats(pageToLoad page:Int) {
        
        APIManager.fetchChats(page) { (result:ApiResult<[MumsnetChat]>) in

            self.pullToRefresh.endRefreshing()
            
            switch result {
                
            case ApiResult.Success(let chats):
                self.chats = chats
                
            case ApiResult.Error(let errorResponse):
                print(errorResponse.error ?? "")
            }
        }
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
}






