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
    dynamic var targetSteps:Int = 10000
    dynamic var targetDistance:Int = 100
    dynamic var targetTime:Int = 60
    dynamic var targetCalories:Int = 2000

    //Returns years
    func getUserAge() -> Int {
        if let birthday = self.birthday {
            let time = Date().timeIntervalSince(birthday)
            return Int(time) / 31556952 //Year in seconds
        }
        return 0
    }
    
}

class DayData: Object {
    dynamic var date:Date? = nil
    dynamic var totalSteps:Int = 0
    dynamic var totalDistance:Int = 0
    dynamic var totalTime:Int = 0
    dynamic var totalCalories:Int = 0
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
    
    func getData(forDay:Date) -> User? {
        let user = realm.objects(DayData.self)
        if user.count > 0 {
//            return user.first
        }
        return nil
    }

}
