//
//  BLEManager.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate {
    
    static let instance = BLEManager()
    
    private var _measurementPoints: [MeasurementPoint] = []
    private var centralManager : CBCentralManager!
    private let centralManagerQueue = DispatchQueue(label: "com.exermote.centralManagerQueue", qos: .userInteractive, attributes: .concurrent)
    private var uiUpdateNeeded = true
    
    var measurementPoints: [MeasurementPoint] {
        return _measurementPoints
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == CBManagerState.poweredOn) {
            
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            
            print("Scanning...")
            
            let delay = DispatchTime.now() + TIME_UNTIL_BLE_MANAGER_PAUSES_WITH_SCANNING
            centralManagerQueue.asyncAfter(deadline: delay) {
                
                central.stopScan()
                
                let pause = DispatchTime.now() + TIME_OF_SCANNING_PAUSE_FOR_BLE_MANAGER
                self.centralManagerQueue.asyncAfter(deadline: pause) {
                    self.centralManagerDidUpdateState(central)
                }
            }
        }
        else {
            print("Not scanning...")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        updateMeasurementPoints(advertisementData: advertisementData, rssi: RSSI)
    }
    
    private func updateMeasurementPoints (advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let measurementPoint = MeasurementPoint(advertisementData: advertisementData, RSSI: RSSI) {
            
            if let index = _measurementPoints.index(where: {$0.nearableIdentifier == measurementPoint.nearableIdentifier}) {
                
                measurementPoint.update(previousMeasurementPoint: _measurementPoints[index])
                _measurementPoints[index] = measurementPoint
            } else {
                
                _measurementPoints.append(measurementPoint)
                _measurementPoints.sort(by: {$0.nearableIdentifier < $1.nearableIdentifier})
            }
            
            let measurementPointsUpdated = _measurementPoints.filter{Date().timeIntervalSince($0.timeStampRecordedAsDate) < MAXIMUM_TIME_SINCE_UPDATE_BEFORE_DISAPPEARING}
            
            uiUpdateNeeded = measurementPointsUpdated.count != _measurementPoints.count ? true : uiUpdateNeeded
            
            _measurementPoints = measurementPointsUpdated
            
            if uiUpdateNeeded {
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_BLE_MANAGER_NEW_PERIPHERALS), object: nil)
                }
                
                uiUpdateNeeded = false
                
                let delay = DispatchTime.now() + 1/UI_MAXIMUM_UPDATE_FREQUENCY
                centralManagerQueue.asyncAfter(deadline: delay) {
                    self.uiUpdateNeeded = true
                }
            }
        }
    }
}
