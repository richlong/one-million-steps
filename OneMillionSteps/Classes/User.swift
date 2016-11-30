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
    dynamic var metric:Bool = true
    dynamic var weight:Float = 0.0
    dynamic var height:Float = 0.0
    dynamic var birthday:Date? = nil
    dynamic var fbId: String? = nil
    dynamic var fbAccessToken: String? = nil
}

class Database {

    let realm = try! Realm()

    func getUser() -> User? {
        let user = realm.objects(User.self) // retrieves all Dogs from the default Realm
        if user.count > 0 {
            return user.first
        }
        return nil
    }
}
