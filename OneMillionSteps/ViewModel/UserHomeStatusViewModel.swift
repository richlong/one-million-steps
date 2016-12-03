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
    var todaysSteps:Int = 0
    var targetSteps:Int = 0
    
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
        bluetoothManager.get30DaysData()
        bluetoothManager.getTargetSteps()
    }
    func userInfoRecieved(userInfo:PedometerUserInfo) {
        
    }
    func monthStepsRecieved(steps:[DaySteps]) {
        print("month steps\(steps)")
        
        if let today = steps.first {
//            todaysSteps = today.steps
            todaysSteps = 2000
        }
        
        if bluetoothManager.targetSteps > 0 {
            targetSteps = bluetoothManager.targetSteps
        }
        
        NotificationCenter.default.post(name: Notification.Name("bluetoothStepsReturned"), object: nil)

    }
    func dayRecieved(steps: Int, day:Int) {
    }
    func deviceTimeout() {
        
    }
    func userDetailsSet() {
        
    }

}
