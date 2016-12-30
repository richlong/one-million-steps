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
            
            let day = DayData()
            
            c += 1
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(day)
            }
        }
        
    }
}