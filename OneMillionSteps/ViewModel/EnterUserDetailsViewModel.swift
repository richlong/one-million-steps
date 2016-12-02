//
//  EnterUserDetailsViewModel.swift
//  OneMillionSteps
//
//  Created by Rich Long on 30/11/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import Foundation
import RealmSwift

class EnterUserDetailsViewModel {
    
    var feet:Int?
    var inches:Int?
    var stones:Int?
    var pounds:Int?

    var meters:Float?
    var kg:Float?
    
    var isMetric = true
    var date:Date?
    func convertHeight(feet:Int,inches:Int) -> Float{
        let i:Float = Float((feet * 12) + inches)
        return i * 2.54
    }
    
    func convertWeight(stones:Int,pounds:Int) -> Float{
        let p:Float = Float((stones * 14) + pounds)
        return p * 0.453592
    }
    
    func saveUseDetails() {
        
        let db = Database()
        guard let user = db.getUser() else {
            //Todo
            print("No user")
            return
        }

        let realm = try! Realm()
        
        var height:Float = 0.0
        var weight:Float = 0.0
        
        if isMetric {
            if let m = meters {
                height = m
            }
            
            if let k = kg {
                weight = k
            }
        }
        else {
            if let f = feet, let i = inches{
                height = convertHeight(feet: f, inches: i)
            }
            
            if let s = stones, let p = pounds{
                weight = convertWeight(stones:s, pounds: p) / 100
            }

        }
        
        try! realm.write {
            
            if let d = date {
                user.birthday = d
            }
            
            if height > 0 {
                user.height = height
            }
            
            if weight > 0 {
                user.weight = weight
            }
            
            user.useMetric = isMetric
        }
        print(user)
        NotificationCenter.default.post(name: Notification.Name("userDetailsSaved"), object: nil)
    }
}
