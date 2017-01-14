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
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    //CoreBluetooth methods
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        if (central.state == CBManagerState.poweredOn)
        {
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning...")
        }
        else
        {
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,                                                   advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        let measurementPoint = MeasurementPoint(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        
        if measurementPoint.companyIdentifier == COMPANY_IDENTIFIER_ESTIMOTE {
            if let index = measurementPoints.index(where: {$0.beaconIdentifier == measurementPoint.beaconIdentifier}) {
                measurementPoints[index] = measurementPoint
            } else {
                measurementPoints.append(measurementPoint)
                measurementPoints.sort(by: {$0.beaconIdentifier < $1.beaconIdentifier})
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPeripherals"), object: nil)
        }
    }

    
    
    
}
