//
//  LoginViewController.swift
//  OneMillionSteps
//
//  Created by Rich Long on 28/11/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import SwiftSpinner

class LoginViewController: UIViewController, LoginButtonDelegate {

    @IBOutlet weak var proceedButton: UIButton!
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.dataSaved(notification:)), name: Notification.Name("userDetailsSaved"), object: nil)

        
        let db = Database()
        if let user = db.getUser() {
            proceedButton.isHidden = false
        }
        else {
            let loginButton = LoginButton(readPermissions: [ .publicProfile,.email ])
            loginButton.center = view.center
            loginButton.delegate = self
            view.addSubview(loginButton)
        }
    }

    func dataSaved(notification: Notification){
        SwiftSpinner.hide()
        proceedButton.isHidden = false
    }

    @IBAction func proceedButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "step2", sender: nil)
    }
    
    //MARK: FB delegate
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        SwiftSpinner.show("Loading...")

        let operation = BlockOperation(block: {
            self.viewModel.saveUserInfo()
        })
        
        OperationQueue.main.addOperation(operation)
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logout")
    }
}
