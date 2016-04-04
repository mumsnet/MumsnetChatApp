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
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Hack to use refreshcontrol
        self.pullToRefresh.addTarget(self, action: #selector(ChatListViewController.refreshTriggered), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.pullToRefresh)
        self.tableView.sendSubviewToBack(self.pullToRefresh)

        self.reloadChats(pageToLoad: 1)
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
        
        // TODO: open Chat Detail
        let chatDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatDetailViewController") as! ChatDetailViewController
        
        let chat = self.chats[indexPath.row]
        chatDetailVC.setup(chat)
        
        self.navigationController?.pushViewController(chatDetailVC, animated: true)
    }
}


