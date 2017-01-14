//
//  MeasurmentPoint.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.


import Foundation
import CoreBluetooth

class MeasurementPoint {
    
    private var _companyIdentifier: String?
    private var _beaconIdentifier: String?
    private var _unknownBytes = [String]()
    private var _xAcceleration = 0.0
    private var _yAcceleration = 0.0
    private var _zAcceleration = 0.0
    private var _durationCurrentState = 0
    private var _durationPreviousSate = 0
    private var _rssi = 0
    
    var companyIdentifier: String {
        if _companyIdentifier == nil {
            _companyIdentifier = "NA"
        }
        return _companyIdentifier!
    }
    
    var beaconIdentifier: String {
        if _beaconIdentifier == nil {
            _beaconIdentifier = "NA"
        }
        return _beaconIdentifier!
    }
    
    var unknownBytes: [String] {
        return _unknownBytes
    }
    
    var xAcceleration: Double {
        return _xAcceleration
    }
    
    var yAcceleration: Double {
        return _yAcceleration
    }
    
    var zAcceleration: Double {
        return _zAcceleration
    }
    
    var durationCurrentState: Int {
        return _durationCurrentState
    }
    
    var durationPreviousState: Int {
        return _durationPreviousSate
    }
    
    var rssi: Int {
        return _rssi
    }

    init(peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        
        let data = advertisementData["kCBAdvDataManufacturerData"] as? Data
        
        self._companyIdentifier = data?.subdata(in: COMPANY_IDENTIFIER_ESTIMOTE_RANGE).hexEncodedString()
        
        if self._companyIdentifier == COMPANY_IDENTIFIER_ESTIMOTE {
        
            self._beaconIdentifier = data?.subdata(in: BEACON_IDENTIFIER_RANGE).hexEncodedString()
            
            self._xAcceleration = hexToAcc(hexData: (data?.subdata(in: X_ACCELERATION_RANGE).hexEncodedString())!)
            self._yAcceleration = hexToAcc(hexData: (data?.subdata(in: Y_ACCELERATION_RANGE).hexEncodedString())!)
            self._zAcceleration = hexToAcc(hexData: (data?.subdata(in: Z_ACCELERATION_RANGE).hexEncodedString())!)
            
            self._durationCurrentState = hexToDur(hexData: (data?.subdata(in: DURATION_CURRENT_STATE_RANGE).hexEncodedString())!)
            self._durationPreviousSate = hexToDur(hexData: (data?.subdata(in: DURATION_PREVIOUS_STATE_RANGE).hexEncodedString())!)
            
            for unknByte in UNKNOWN_BYTES_ARRAY {
                self._unknownBytes.append((data?.subdata(in: unknByte..<unknByte+1).hexEncodedString())!)
            }
            
            self._rssi = Int(RSSI)
            
            print("Company Identifier: \(self.companyIdentifier) Beacon Identifier: \(self.beaconIdentifier) x Acceleration: \(self.xAcceleration) y Acceleration: \(self.yAcceleration) z Acceleration: \(self.zAcceleration) Duration Current State: \(self.durationCurrentState) Duration Previous State: \(self.durationPreviousState) Unknown Bytes: \(self.unknownBytes) RSSI: \(self.rssi)")
        }
    }
    
    func hexToAcc(hexData: String) -> Double {
        var accDec = Double(Int8(bitPattern: UInt8(strtoul(hexData, nil, 16))))/Double(CALIBRATION_ACCELERATION)
        accDec = round(accDec*100)/100
        return Double(accDec)
    }
    
    func hexToDur(hexData: String) -> Int {
        let durDec = Int(UInt8(hexData, radix: 16)!)
        return durDec
    }
}
