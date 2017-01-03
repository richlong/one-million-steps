//
//  DataSync.swift
//  OneMillionSteps
//
//  Created by Rich Long on 03/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import Foundation
import RealmSwift

class PastDataSync {
    
    let monthSteps:[DaySteps]
    let monthActivity:[DayActivity]
    init(withMonthSteps:[DaySteps], monthActivity:[DayActivity]) {
        self.monthSteps = withMonthSteps
        self.monthActivity = monthActivity
    }
    
    func syncData() {

        var c = 0
        for day in monthSteps {
            
            let realm = try! Realm()

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            if let date:Date = dateFormatter.date(from: day.date) {
                
                let dayData = DayData()
                dayData.date = date
                
                dayData.totalSteps = day.steps
                dayData.totalCalories = day.calories
                
                let dayActivity = monthActivity[c]
                dayData.totalDistance = dayActivity.distance
                dayData.totalTime = dayActivity.time
                
                saveDayData(data: dayData, inRealm: realm)
                

            }
            c += 1
        }
        
    }
    
    //Check date exists, if so return object for update
    internal func existingDayObject(forDate:Date, inRealm realm:Realm) -> DayData? {
        
        let predicate = NSPredicate(format: "date == %@", forDate as NSDate)
        let results = realm.objects(DayData.self).filter(predicate)

        if results.count > 0 {
            return results.first
        }
        else {
            return nil
        }

    }
    
    //If existing date and data is different, update.
    internal func saveDayData(data:DayData, inRealm realm:Realm) {
        
        if let existingDate = existingDayObject(forDate: data.date!, inRealm: realm) {
            
            if data.totalSteps > existingDate.totalSteps {
                realm.beginWrite()
                existingDate.totalSteps = data.totalSteps
                existingDate.totalCalories = data.totalCalories
                existingDate.totalDistance = data.totalDistance
                existingDate.totalTime = data.totalTime
                try! realm.commitWrite()
            }
        }
        else {
            try! realm.write {
                realm.add(data)
            }
        }
        
    }
}
