//
//  UserHomeStatusViewModel.swift
//  OneMillionSteps
//
//  Created by Rich Long on 02/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import Foundation

class UserHomeStatusViewModel: PedometerDelegate {
    
    let bluetoothManager = BluetoothManager()
    var pedometerReady = false
    var todaysSteps:Int? = 0
    var targetSteps:Int? = 2000
    var todaysCalories:Int? = 0
    var targetCalories:Int? = 2000
    var todaysDistance:Int? = 0
    var targetDistance:Int? = 2000
    var todaysTime:Int? = 0
    var targetTime:Int? = 60
    
    
    init() {
        bluetoothManager.delegate = self
    }
    func connectToPedometer() {
        bluetoothManager.reset()
        bluetoothManager.startScan()
    }
    func deviceFound(name:String) {
        
    }
    func deviceReady() {
        bluetoothManager.getTargetSteps()
        bluetoothManager.getTodaysData()
    }
    func userInfoRecieved(userInfo:PedometerUserInfo) {
        
    }
    func monthStepsRecieved(steps:[DaySteps], activity:[DayActivity]) {
        let data = PastDataSync(withMonthSteps: steps, monthActivity: activity)
        data.syncData()
    }
    
    internal func singleDayStepsRecieved(steps: [DaySteps], activity: [DayActivity]) {
        
        if bluetoothManager.targetSteps > 0 {
            targetSteps = bluetoothManager.targetSteps
        }
        
        if let today = steps.first {
            todaysSteps = today.steps
            todaysCalories = today.calories
        }
        
        if let activity = activity.first {
            todaysDistance = activity.distance
            todaysTime = activity.time
        }
        
        bluetoothManager.get30DaysData()

        NotificationCenter.default.post(name: Notification.Name("bluetoothStepsReturned"), object: nil)

    }

    func dayRecieved(steps: Int, day:Int) {
    }
    func deviceTimeout() {
        bluetoothManager.reset()
        NotificationCenter.default.post(name: Notification.Name("bluetoothError"), object: nil)
    }
    func userDetailsSet() {
    }

}
