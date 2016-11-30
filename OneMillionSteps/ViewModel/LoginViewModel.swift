//
//  LoginViewModel.swift
//  OneMillionSteps
//
//  Created by Rich Long on 29/11/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import Foundation
import FacebookCore
import FBSDKCoreKit
import RealmSwift

class LoginViewModel {
    
    var detailsSaved:Bool = false
    
    func saveUserInfo() {
        
        if (AccessToken.current != nil) {
            
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me",
                                                                   parameters: ["fields":"first_name,last_name,email,gender,birthday"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil) {
                    print("Error: \(error)")
                    NotificationCenter.default.post(name: Notification.Name("userDetailsFailed"), object: nil)
                }
                else {
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    self.saveToDatabase(userDetails: data)
                }
            })
        }
        else {
            NotificationCenter.default.post(name: Notification.Name("userDetailsFailed"), object: nil)
        }

    }
    
    func saveToDatabase(userDetails:[String : AnyObject]) {
    
        let user = User()
        if let firstName = userDetails["first_name"] {
            user.firstName = firstName as! String
        }
        if let lastName = userDetails["last_name"] {
            user.lastName = lastName as! String
        }
        if let email = userDetails["email"] {
            user.email = email as! String
        }
        if let gender = userDetails["gender"] {
            user.gender = gender as! String
        }
        if let dob = userDetails["birthday"] as! String? {
            let birthdayFormatter = DateFormatter()
            birthdayFormatter.dateFormat = "MM/DD/YYYY"
            if let birthdayDate = birthdayFormatter.date(from: dob) {
                user.birthday = birthdayDate
            }
        }

        if let token = AccessToken.current?.authenticationToken {
            user.fbAccessToken = token 
        }
        if let id = AccessToken.current?.userId {
            user.fbId = id 
        }

        let realm = try! Realm()
        try! realm.write {
            realm.add(user)
            NotificationCenter.default.post(name: Notification.Name("userDetailsSaved"), object: nil)
        }
    }
    
}

