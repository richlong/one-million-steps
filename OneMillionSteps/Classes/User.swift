//
//  User.swift
//  
//
//  Created by Rich Long on 29/11/2016.
//
//

import Foundation
import Realm
import RealmSwift

class User: Object {
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var email = ""
    dynamic var gender = ""
    dynamic var useMetric:Bool = true
    dynamic var weight:Float = 0.0
    dynamic var height:Float = 0.0
    dynamic var birthday:Date? = nil
    dynamic var fbId: String? = nil
    dynamic var fbAccessToken: String? = nil
    dynamic var bluetoothDeviceId: String? = nil
    
    func getUserAge() -> Int {
        
        if let birthday = self.birthday {
            let time = Date().timeIntervalSince(birthday)
            return Int(time) / 31556952 //Year in seconds
        }
        return 0
    }
    
}

class Database {

    let realm = try! Realm()

    func getUser() -> User? {
        let user = realm.objects(User.self)
        if user.count > 0 {
            return user.first
        }
        return nil
    }
}
