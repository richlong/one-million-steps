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
    dynamic var birthday:Date? = nil
    dynamic var fbId: String? = nil // optionals supported
    dynamic var fbAccessToken: String? = nil // optionals supported

//    let dogs = List<Dog>()
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
