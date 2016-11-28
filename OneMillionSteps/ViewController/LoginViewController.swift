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

class LoginViewController: UIViewController, LoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let accessToken = AccessToken.current {
            print(accessToken)
        }
        else {
            let loginButton = LoginButton(readPermissions: [ .publicProfile,.email ])
            loginButton.center = view.center
            view.addSubview(loginButton)
        }
    }
 
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print(result)
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logout")
    }
}
