//
//  BluetoothManager.swift
//  BluetoothTest
//
//  Created by Rich Long on 27/10/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit
import CoreBluetooth

enum HexPacketPrefix:UInt8 {
    case DaysData = 0x43
    case GetUserDetails = 0x42
    case SetUserDetails = 0x02
    case RealTimeStepMeter = 0x09
    case SetTime = 0x01
    case GetTime = 0x41
    case FactoryReset = 0x12
    case GetCurrentActivityData = 0x48
    case StepError = 0xC3
    case GetTotalActivityForDay = 0x07
    case GetTargetSteps = 0x4B
}

struct DaySteps {
    let date:String
    let steps:Int
    let calories:Int
}

struct DayActivity {
    let distance:Int
    let time:Int
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegate:PedometerDelegate?
    var centralManager: CBCentralManager?
    var discoveredPeripheral: CBPeripheral?
    
    var transferCharacteristic:CBCharacteristic?
    var recieveCharacteristic:CBCharacteristic?
    
    let serviceUUID:CBUUID = CBUUID.init(string: "FFF0")
    let transferUUID:CBUUID = CBUUID.init(string: "FFF6")
    let recieveUUID:CBUUID = CBUUID.init(string: "FFF7")
    
    let pastDataLimit = 29 //30 days
    var currentDayStepCount:Int = 0
    var stepPacketCount:Int = 0
    var currentDay:Int = 0
    var monthSteps:[DaySteps] = []
    var monthActivity:[DayActivity] = []
    var isRecievingStepData = false
    var currentDayRequestTotal = 0
    var isGettingSingleDay = false
    var timeOut:Timer = Timer()
    var targetSteps = 0
    func startScan() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOff:
            print("Off")
        case .poweredOn:
            print("On")
            scan()
        case .resetting:
            print("Resetting")
        case .unauthorized:
            print("Unauth")
        case .unknown:
            print("unknown")
        case .unsupported:
            print("Unsupport")
        }
        print(central)
    }
    
    private func scan() {
        delegate?.pedometerReady = false
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
        print("Scanning started")
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered \(peripheral.name) at \(RSSI)")
        
        // Ok, it's in range - have we already seen it?
        
        if let name:String = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            if name.contains("NewgenMedicals") {
                
                discoveredPeripheral = peripheral
                
                // And connect
                print("Connecting to peripheral \(peripheral)")
                centralManager?.connect(peripheral, options: nil)
                delegate?.deviceFound(name: peripheral.name!)
//                delegate?.deviceFound(name: "Device found")
            }
            else {
                delegate?.deviceFound(name: "Unable to find device")
            }
            
        }
        else {
            print("Cannot connect to peripheral \(peripheral)")
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Peripheral Connected")
        
        // Stop scanning
        centralManager?.stopScan()
        print("Scanning stopped")
        
        // Clear the data that we may already have
        //        data.length = 0
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([serviceUUID])
        
    }
    
    
    
    //MARK: CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            print(service)
            
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // Deal with errors (if any)
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            cleanup()
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        
        // Again, we loop through the array, just in case.
        for characteristic in characteristics {
            
            if characteristic.uuid == transferUUID {
                self.transferCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("tx set: \(characteristic)")
            }
            
            if characteristic.uuid == recieveUUID  {
                self.recieveCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("rx set: \(characteristic)")
            }
        }
        
        // Once this is complete, we just need to wait for the data to come in.
        
        if self.transferCharacteristic != nil && self.recieveCharacteristic != nil {
            // RX & TX Set - request info
            delegate?.pedometerReady = true
            delegate?.deviceReady()
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        let data = characteristic.value!
        let hexArray:[UInt8] = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        
        if hexArray.count > 0 {
            processPacket(packet: hexArray)
        }
        else {
            print("Invalid data recieved")
            return
        }
    }
    
    //MARK: Clean up methods
    
    /** Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    
    func reset() {
        cleanup()
    }
    
    private func cleanup() {
        // Don't do anything if we're not connected
        // self.discoveredPeripheral.isConnected is deprecated
        guard discoveredPeripheral?.state == .connected else {
            return
        }
        
        // See if we are subscribed to a characteristic on the peripheral
        guard let services = discoveredPeripheral?.services else {
            cancelPeripheralConnection()
            return
        }
        
        for service in services {
            guard let characteristics = service.characteristics else {
                continue
            }
            
            for characteristic in characteristics {
                if (characteristic.uuid.isEqual(transferCharacteristic) ||
                    characteristic.uuid.isEqual(recieveCharacteristic)) &&
                    characteristic.isNotifying {
                    discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                    // And we're done.
                    return
                }
            }
        }
        cancelPeripheralConnection()
    }
    
    private func cancelPeripheralConnection() {
        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager?.cancelPeripheralConnection(discoveredPeripheral!)
    }
    
    //MARK:
    //MARK: Communication Methods
    
    func sendPacketToDevice(firstBytes:[UInt8]) {
        
        let data = Data.init(bytes: Packet.createPacket(firstBytes: firstBytes))
        self.discoveredPeripheral?.writeValue(data, for: transferCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func processPacket(packet:[UInt8]) {
        
        let firstByte:UInt8 = packet.first!

        switch firstByte {
        case HexPacketPrefix.SetTime.rawValue:
            print("Time set: \(packet)")
            break
        case HexPacketPrefix.DaysData.rawValue:
            parseDaysDetailedData(packet: packet)
            break
        case HexPacketPrefix.GetTime.rawValue:
            parseDate(packet: packet)
            break
        case HexPacketPrefix.RealTimeStepMeter.rawValue:
            print("Realtime step: \(packet)")
            break
        case HexPacketPrefix.GetUserDetails.rawValue:
            parseUserDetails(packet: packet)
            break
        case HexPacketPrefix.SetUserDetails.rawValue:
            parseSetUserDetails(packet: packet)
            break
        case HexPacketPrefix.StepError.rawValue:
            print("StepError: \(packet)")
            stepPacketCount += 1
            break
        case HexPacketPrefix.GetTotalActivityForDay.rawValue:
            parseDaysData(packet: packet)
            break
        case HexPacketPrefix.GetTargetSteps.rawValue:
            parseTargetSteps(packet: packet)
            break
            
        default:
            print("Packet unknown: \(packet)")
        }
        
    }
    
    //MARK: Realtime
    
    func startRealtimeTracking() {
        sendPacketToDevice(firstBytes:  [HexPacketPrefix.RealTimeStepMeter.rawValue])
    }
    
    //MARK: Todays data
    
    func get30DaysData() {
        print("Get 30 days data")
        isRecievingStepData = true
        resetStepData()
        currentDayRequestTotal = pastDataLimit
        getDaysData(day: 0)
    }
    
    func getTodaysData() {
        print("Get today's data")
        isRecievingStepData = true
        isGettingSingleDay = true
        resetStepData()
        currentDayRequestTotal = 0
        getDaysData(day: 0)
    }
    
    func resetStepData() {
        currentDay = 0;
        stepPacketCount = 0
        currentDayStepCount = 0
        monthSteps.removeAll()
        monthActivity.removeAll()
    }
    
    func getDaysData(day:Int) {
        //Day 0 = today, 1 = yesterday etc up to 30.
        print("Getting day: \(day)")
        sendPacketToDevice(firstBytes:  [HexPacketPrefix.GetTotalActivityForDay.rawValue, UInt8(day)])
        restartTimer()
    }
    
    func restartTimer() {
        //For timeOut
        print("Time reset")
        timeOut.invalidate()
        // start the timer
        timeOut = Timer.scheduledTimer(timeInterval: 15.0,
                                       target: self,
                                       selector: #selector(deviceTimeout),
                                       userInfo: nil,
                                       repeats: false)
    }
    
    func parseDaysDetailedData(packet:[UInt8]) {
        
        //        //Each day's data contains 96 packets.
        //        stepPacketCount += 1
        //
        //        //Check if finished
        //        if currentDay > currentDayRequestTotal {
        //            getStepsFinished()
        //            return
        //        }
        //
        //        if (packet[1] == 0xFF) {
        //            //Invalid data
        //            print("Day \(currentDay) data invalid")
        //            currentDay += 1
        //            monthSteps.append(0)
        //            delegate?.dayRecieved(steps: -1, day: currentDay)
        //            getDaysData(day: currentDay)
        //            currentDayStepCount = 0
        //            return
        //        }
        //
        //        // 0x00 = Activity data which is what we want
        //        if (packet[6] == 0x00) {
        //            let steps = Int(packet[9])+Int(packet[10])*256
        //            currentDayStepCount += steps
        //        }
        //        // 0xff = Sleep data
        //        else if (packet[6] == 0xff) {
        //            //Not req
        //        }
        //
        //        //Each step req returns 96 packets per day
        //        if stepPacketCount == 96 {
        //            //All step packets recieved
        //            print("Current day steps: \(currentDayStepCount)")
        //            stepPacketCount = 0
        //            monthSteps.append(currentDayStepCount)
        //            delegate?.dayRecieved(steps: currentDayStepCount, day: currentDay)
        //            currentDayStepCount = 0
        //            if isGettingSingleDay {
        //                getStepsFinished()
        //            }
        //            else {
        //                currentDay += 1
        //                getDaysData(day: currentDay)
        //            }
        //        }
        
    }
    
    func getStepsFinished() {
        timeOut.invalidate()
        //        print("Month array: \(monthSteps)")
        
        if isGettingSingleDay {
            delegate?.singleDayStepsRecieved(steps: monthSteps,activity:monthActivity)
        }
        else {
            delegate?.monthStepsRecieved(steps: monthSteps,activity:monthActivity)
        }
        
        isRecievingStepData = false
        isGettingSingleDay = false
    }
    
    //MARK: Total activity
    
    func parseDaysData(packet:[UInt8]) {
        
//        print("TotalActivity: \(packet)")
        
        if currentDay > currentDayRequestTotal {
            getStepsFinished()
            return
        }
        
        if (packet[1] == 0) { //0 = Steps
            if (packet[3] != 0 && packet[4] != 0 && packet[5] != 0) {
                
                let stepPacket1 = Int(packet[6]) * 256 * 256
                let stepPacket2 = Int(packet[7]) * 256
                let stepPacket3 = Int(packet[8])
                let totalSteps = stepPacket1 + stepPacket2 + stepPacket3
                
                let calPacket1 = Int(packet[12]) * 256 * 256
                let calPacket2 = Int(packet[13]) * 256
                let calPacket3 = Int(packet[14])
                let totalCalories = (calPacket1 + calPacket2 + calPacket3) / 100
                
                let y = String(format:"%2X", packet[3])
                let m = String(format:"%2X", packet[4])
                let d = String(format:"%2X", packet[5])
                
                let date = "\(d)/\(m)/\(y)"
                
                let day = DaySteps(date: date, steps: totalSteps, calories: totalCalories)
                
                print("Date: \(day.date) steps: \(day.steps)")
                monthSteps.append(day)
                
            }
            else {
                //No day data
                print("Current day: \(currentDay) no step data")
                monthSteps.append(DaySteps(date: "0", steps: 0, calories:0))
            }
            getDaysData(day: currentDay)
            
        }
        else if (packet[1] == 1) { //1 = Walking distance
            
            let distancePacket1 = Int(packet[6]) * 256 * 256
            let distancePacket2 = Int(packet[7]) * 256
            let distancePacket3 = Int(packet[8])
            let totaldistances = distancePacket1 + distancePacket2 + distancePacket3
            
            let timePacket1 = Int(packet[9]) * 256
            let timePacket2 = Int(packet[10])
            let totaltimes = timePacket1 + timePacket2
            
            monthActivity.append(DayActivity(distance: totaldistances, time: totaltimes))

            currentDay += 1

        }
    }
    
    //MARK: Device time
    
    /*
     0x01 AA BB CC DD EE FF 00 00 00 00 00 00 00 00 CRC
     AA year;BB month;CC day;DD hour;EE minute;FF second。format is BCD，for
     example,12 year，AA = 0x12
     
     Check right and execute OK, then return:: 0x01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 CRC Check error and execute Fail, then return: 0x81 00 00 00 00 00 00 00 00 00 00 00 00 00 00 CRC
     */
    
    func setDeviceTime() {
        
        let date = Date()
        print("Setting device date to: \(date)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmss"
        let dateString = dateFormatter.string(from: date)
        let characters = Array(dateString.characters)
        
        var packetArray:[UInt8] = []
        packetArray.append(HexPacketPrefix.SetTime.rawValue)
        
        let year = "\(characters[0])\(characters[1])"
        packetArray.append(Packet.stringToHex(string: year)!)
        
        let month = "\(characters[2])\(characters[3])"
        packetArray.append(Packet.stringToHex(string: month)!)
        
        let day = "\(characters[4])\(characters[5])"
        packetArray.append(Packet.stringToHex(string: day)!)
        
        let hour = "\(characters[6])\(characters[7])"
        packetArray.append(Packet.stringToHex(string: hour)!)
        
        let minute = "\(characters[8])\(characters[9])"
        packetArray.append(Packet.stringToHex(string: minute)!)
        
        let second = "\(characters[10])\(characters[11])"
        packetArray.append(Packet.stringToHex(string: second)!)
        
        sendPacketToDevice(firstBytes:packetArray)
    }
    
    func getDeviceTime() {
        sendPacketToDevice(firstBytes:  [HexPacketPrefix.GetTime.rawValue])
    }
    
    func parseDate(packet:[UInt8]) {
        let packetArray = Packet.convertPacketToIntArrayFromHex(packet: packet)
        print("parseDate: \(packetArray)")
    }
    
    //MARK: User details
    
    /*
     0x02 AA BB CC DD EE FF 00 00 00 00 00 00 00 00CRC
     AA:gender(0 stands for female，1 stands for male)，BB:age，CC:height，DD:weight， EE:stride length;
     
     Check right and execute OK, then return: 0x02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 CRC
     Check error and execute Fail, then return:0x82 00 00 00 00 00 00 00 00 00 00 00 00 00 00 CRC
     
     */
    func setUserDetails(gender:Int,age:Int,height:Int,weight:Int,strideLength:Int) {
        
        var packetArray:[UInt8] = []
        packetArray.append(HexPacketPrefix.SetUserDetails.rawValue)
        packetArray.append(UInt8(gender))
        packetArray.append(UInt8(age))
        packetArray.append(UInt8(height))
        packetArray.append(UInt8(weight))
        packetArray.append(UInt8(strideLength))
        
        print("Setting User details: \(packetArray)")
        sendPacketToDevice(firstBytes:packetArray)
    }
    
    func parseSetUserDetails(packet:[UInt8]) {
        delegate?.userDetailsSet()
    }

    
    func getUserDetails() {
        sendPacketToDevice(firstBytes:  [HexPacketPrefix.GetUserDetails.rawValue])
    }
    
    func parseUserDetails(packet:[UInt8]) {
        
        let packetArray = Packet.convertPacketToIntArray(packet: packet)
        
        if packetArray.count > 0 {
            let user = PedometerUserInfo(age: packetArray[2], height: packetArray[3], weight: packetArray[4], stridgeLength: packetArray[5])
            delegate?.userInfoRecieved(userInfo: user)
        }
        
        //        print("parseUserDetails\(packetArray)")
    }
    
    //MARK: Current activitiy data
    
    func getCurrentActivityData() {
        sendPacketToDevice(firstBytes:  [HexPacketPrefix.GetCurrentActivityData.rawValue])
    }
    
    //MARK: GetTargetSteps
    
    func getTargetSteps() {
        sendPacketToDevice(firstBytes:  [HexPacketPrefix.GetTargetSteps.rawValue])
    }
    
    func parseTargetSteps(packet:[UInt8]) {
        
        let packetArray = Packet.convertPacketToIntArray(packet: packet)
        
        print(packetArray)
        

        let a = Int(packet[1])*256*256
        let b = Int(packet[2])*256
        let c = Int(packet[3])
        let target = Int(a+b+c)
        targetSteps = target
    }

    
    
    //MARK:Factory Reset
    
    func factoryResetDevice() {
        print("Factory reset device...")
        sendPacketToDevice(firstBytes:  [HexPacketPrefix.FactoryReset.rawValue])
    }
    
    //MARK: Timeout
    
    func deviceTimeout() {
        print("Timeout")
        delegate?.deviceTimeout()
    }
    
}

struct PedometerUserInfo {
    var age:Int
    var height:Int
    var weight:Int
    var stridgeLength:Int
}
