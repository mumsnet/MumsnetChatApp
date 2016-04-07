//
//  LoginVC.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 05/04/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var buttonSpinner: UIActivityIndicatorView!
    @IBOutlet weak var crossButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.emailField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.AllEvents)
        self.passwordField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.AllEvents)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        
        self.enableLoginButton(false)
        self.crossButton.hidden = !UserManager.isLoggedIn()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let user = UserManager.currentUser() {
            self.emailField.text = user.email
        }
    }
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    func showSpinner(show isShowing:Bool) {
        
        if isShowing {
            self.buttonSpinner.startAnimating()
            UIView.animateWithDuration(0.3, animations: { 
                self.buttonSpinner.alpha = 1
            })
        }
        else {
            UIView.animateWithDuration(0.3, animations: { 
                
                self.buttonSpinner.alpha = 0
                }, completion: { (completion) in
                    self.buttonSpinner.stopAnimating()
            })
        }
    }
    
    func closeLoginVC() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonPressed(sender: UIButton) {
    
        self.dismissKeyboard()
        self.errorLabel.text = ""
        
        self.showSpinner(show: true)
        self.enableLoginButton(false)
        UserManager.loginUser(self.emailField.text ?? "", password: self.passwordField.text ?? "") { (result) in
            
            self.showSpinner(show: false)
            self.enableLoginButton(true)
            
            switch result {
                
            case ApiResult.Success(_):
                // Successful login, close
                self.closeLoginVC()
                
            case ApiResult.Error(let errorResponse):
                print(errorResponse.error)
                self.errorLabel.text = errorResponse.error.debugDescription ?? ""
            }
        }
    }
    
    @IBAction func crossButtonPressed(sender: UIButton) {
        
        self.closeLoginVC()
    }
    
    // MARK: - TextField Delegates
    
    func textFieldDidChange(textField:UITextField) {
        
        self.enableLoginButton((self.passwordField.text ?? "").characters.count > 0 && (self.emailField.text ?? "").characters.count > 0)
        
    }
    
    func enableLoginButton(enabled:Bool) {
        
        UIView.animateWithDuration(0.1, animations: {
            
            if enabled {
                self.loginButton.enabled = true
                self.loginButton.alpha = 1
                
            }
            else {
                self.loginButton.enabled = false
                self.loginButton.alpha = 0.5
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        }
        else if textField == self.passwordField {
            self.dismissKeyboard()
        }
        
        return false
    }
}



