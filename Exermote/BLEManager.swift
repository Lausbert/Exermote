//
//  BLEManager.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class BLEManager: NSObject, CBCentralManagerDelegate {
    
    static let instance = BLEManager()
    
    private var _iBeaconStates: [IBeaconState] = []
    private var centralManager : CBCentralManager!
    private let centralManagerQueue = DispatchQueue(label: "com.exermote.centralManagerQueue", qos: .userInteractive, attributes: .concurrent)
    private var uiUpdateNeeded = true
    
    var iBeaconStates: [IBeaconState] {
        return _iBeaconStates
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == CBManagerState.poweredOn) {
            
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            
            print("Scanning...")
            
            if TIME_OF_SCANNING_PAUSE_FOR_BLE_MANAGER > 0.0 {
                let delay = DispatchTime.now() + TIME_UNTIL_BLE_MANAGER_PAUSES_WITH_SCANNING
                centralManagerQueue.asyncAfter(deadline: delay) {
                    
                    central.stopScan()
                    
                    let pause = DispatchTime.now() + TIME_OF_SCANNING_PAUSE_FOR_BLE_MANAGER
                    self.centralManagerQueue.asyncAfter(deadline: pause) {
                        self.centralManagerDidUpdateState(central)
                    }
                }
            }
        }
        else {
            print("Not scanning...")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        updateIBeaconStates(advertisementData: advertisementData, rssi: RSSI)
    }
    
    func updateIBeaconStates (advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let iBeaconState = IBeaconState(advertisementData: advertisementData, RSSI: RSSI) {
            
            if let index = _iBeaconStates.index(where: {$0.nearableIdentifier == iBeaconState.nearableIdentifier}) {
                
                iBeaconState.update(previousIBeaconState: _iBeaconStates[index])
                _iBeaconStates[index] = iBeaconState
            } else {
                
                _iBeaconStates.append(iBeaconState)
                _iBeaconStates.sort(by: {$0.nearableIdentifier < $1.nearableIdentifier})
            }
            
            let selectedIBeaconStates = BLEManager.instance.iBeaconStates.filter{$0.isSelected}
            
            if selectedIBeaconStates.isEmpty {
                let iBeaconStatesUpdated = _iBeaconStates.filter{Date().timeIntervalSince($0.timeStampRecordedAsDate) < MAXIMUM_TIME_SINCE_UPDATE_BEFORE_DISAPPEARING}
                UIApplication.shared.isIdleTimerDisabled = false
                
                uiUpdateNeeded = iBeaconStatesUpdated.count != _iBeaconStates.count ? true : uiUpdateNeeded
                
                _iBeaconStates = iBeaconStatesUpdated
            } else {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            
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
