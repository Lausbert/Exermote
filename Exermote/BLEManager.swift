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
    var centralManager : CBCentralManager!
    
    var measurementPoints: [MeasurementPoint] = []
    
    
    override init() {
        super.init()
        let centralManagerQueue = DispatchQueue.global(qos: .userInteractive)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        if (central.state == CBManagerState.poweredOn)
        {
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning...")
        }
        else
        {
            print("Not scanning...")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,                                                   advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        let measurementPoint = MeasurementPoint(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        
        if measurementPoint.companyIdentifier == COMPANY_IDENTIFIER_ESTIMOTE {
            
            if let index = measurementPoints.index(where: {$0.beaconIdentifier == measurementPoint.beaconIdentifier}) {
                measurementPoint.wasUpdated(previousMeasurementPoint: measurementPoints[index])
                measurementPoints[index] = measurementPoint
            } else {
                measurementPoints.append(measurementPoint)
                measurementPoints.sort(by: {$0.beaconIdentifier < $1.beaconIdentifier})
            }
            
            measurementPoints = measurementPoints.filter{Date().timeIntervalSince($0.timeStamp) < MAXIMUM_TIME_SINCE_UPDATE_BEFORE_DISAPPEARING}
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPeripherals"), object: nil)
            }
        }
    }

    
    
    
}
