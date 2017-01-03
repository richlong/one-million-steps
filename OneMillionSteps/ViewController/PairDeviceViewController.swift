//
//  PairDeviceViewController.swift
//  BluetoothTest
//
//  Created by Rich Long on 09/11/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit
import CoreBluetooth
import RealmSwift

protocol PedometerDelegate {
    var pedometerReady:Bool {get set}
    func deviceFound(name:String)
    func deviceReady()
    func userInfoRecieved(userInfo:PedometerUserInfo)
    func monthStepsRecieved(steps:[DaySteps],activity:[DayActivity])
    func singleDayStepsRecieved(steps:[DaySteps],activity:[DayActivity])
    func deviceTimeout()
    func userDetailsSet()
}

class PairDeviceViewController: UIViewController, PedometerDelegate {
    
    internal var pedometerReady: Bool = false
    
    let bluetoothManager = BluetoothManager()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceId: UILabel!
    
    @IBOutlet weak var getUserInfoButton: UIButton!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var todaysStepsButton: UIButton!
    
    @IBOutlet weak var getMonthStepsButton: UIButton!
    @IBOutlet weak var monthStepsTextView: UITextView!
    @IBOutlet weak var pairingLabel: UILabel!
    
    var deviceIdString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothManager.delegate = self
        activityIndicator.isHidden = true
    }
    
    func deviceFound(name:String) {
        statusLabel.text = "Device found: \(name)"
        
        if let deviceIdString = bluetoothManager.discoveredPeripheral?.identifier {
            
            self.deviceIdString = deviceIdString.uuidString
            print("Device ID: \(deviceIdString)")
        }
    }
    
    func userInfoRecieved(userInfo:PedometerUserInfo) {
        userInfoLabel.text = "Age: \(userInfo.age) Height: \(userInfo.height) Weight: \(userInfo.weight) Stride: \(userInfo.stridgeLength)"
    }
    
    internal func monthStepsRecieved(steps: [DaySteps],activity:[DayActivity]) {
        
        var str = ""
        var c = 0
        for day in steps {
            str.append("\nDay: \(day.date) Steps: \(day.steps)")
            c += 1
        }
        
        monthStepsTextView.text = str
        
    }
    
    internal func singleDayStepsRecieved(steps: [DaySteps], activity: [DayActivity]) {

    }
    
    internal func deviceReady() {
        bluetoothManager.setDeviceTime()
        setUserDetails()
    }
    
    func setUserDetails() {
        let db = Database()
        if let user = db.getUser() {
            
            var gender = 0
            var stride = user.height * 0.413
            if user.gender == "male" {
                gender = 1
                stride = user.height * 0.415
            }
            
            bluetoothManager.setUserDetails(gender: gender,
                                            age: user.getUserAge(),
                                            height: Int(user.height),
                                            weight: Int(user.weight),
                                            strideLength: Int(stride))
            
            let realm = try! Realm()
            
            try! realm.write {
                user.bluetoothDeviceId = deviceIdString
            }
        }
    }
    
    internal func userDetailsSet() {
        statusLabel.text = "Device succesfully added"
        finishButton.isHidden = false
        activityIndicator.isHidden = true
        bluetoothManager.reset()

    }

    internal func dayRecieved(steps: Int, day:Int) {
//        monthStepsTextView.text.append("\nDay: \(day) Steps: \(steps)")
    }
    
    
    internal func deviceTimeout() {
        bluetoothManager.reset()
        statusLabel.text = "Device Timeout - search again"
    }
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        bluetoothManager.startScan()
        statusLabel.text = "Searching..."
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    @IBAction func getUserInfoAction(_ sender: Any) {
        
        if pedometerReady {
            bluetoothManager.getUserDetails()
        }
        else {
//            userInfoLabel.text = "Device not ready"
        }
    }
    
    @IBAction func getTodaysStepsAction(_ sender: Any) {
        if pedometerReady && !bluetoothManager.isRecievingStepData {
            bluetoothManager.getTodaysData()
            monthStepsTextView.text = "Calculating..."
        }
        else {
            monthStepsTextView.text = "Device not ready"
        }
        
    }
    
    @IBAction func getMonthStepsAction(_ sender: Any) {
        if pedometerReady &&
            !bluetoothManager.isRecievingStepData {
            bluetoothManager.get30DaysData()
            monthStepsTextView.text = "Calculating, can take a while."
            
        }
        else {
            monthStepsTextView.text = "Device not ready"
        }
    }
    
    @IBAction func debugAction(_ sender: Any) {
        //        FLEXManager.shared().showExplorer()
        bluetoothManager.reset()
    }
    
    @IBAction func finishButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "userRegComplete", sender: nil)
    }

}
