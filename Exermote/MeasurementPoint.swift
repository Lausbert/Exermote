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
    private var _nearableIdentifier: String?
    private var _unknownBytes = [String]()
    private var _xAcceleration: Double?
    private var _yAcceleration: Double?
    private var _zAcceleration: Double?
    private var _durationCurrentState: Int?
    private var _durationPreviousSate: Int?
    private var _rssi: Int?
    private var _timeStamp: Date!
    private var _count = 0
    private var _frequency: Double?
    private var _isSelected = false
    
    var companyIdentifier: String {
        if _companyIdentifier == nil {
            return ERROR_VALUE_STRING
        }
        return _companyIdentifier!
    }
    
    var nearableIdentifier: String {
        if _nearableIdentifier == nil {
            return ERROR_VALUE_STRING
        }
        return _nearableIdentifier!
    }
    
    var unknownBytes: [String] {
        return _unknownBytes
    }
    
    var xAcceleration: Double? {
        if _xAcceleration == nil {
            return ERROR_VALUE_DOUBLE
        }
        return _xAcceleration
    }
    
    var yAcceleration: Double? {
        if _yAcceleration == nil {
            return ERROR_VALUE_DOUBLE
        }
        return _yAcceleration
    }
    
    var zAcceleration: Double? {
        if _zAcceleration == nil {
            return ERROR_VALUE_DOUBLE
        }
        return _zAcceleration
    }
    
    var durationCurrentState: Int? {
        if _durationCurrentState == nil {
            return ERROR_VALUE_INT
        }
        return _durationCurrentState
    }
    
    var durationPreviousState: Int? {
        if _durationPreviousSate == nil {
            return ERROR_VALUE_INT
        }
        return _durationPreviousSate
    }
    
    var rssi: Int? {
        if _rssi == nil {
            return ERROR_VALUE_INT
        }
        return _rssi
    }
    
    var timeStamp: Date {
        return _timeStamp
    }
    
    var count: Int {
        return _count
    }
    
    var frequency: Double? {
        if _frequency == nil {
            return ERROR_VALUE_DOUBLE
        }
        return _frequency
    }
    
    var isSelected: Bool {
        return _isSelected
    }
    
    init(peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        
        let data = advertisementData["kCBAdvDataManufacturerData"] as? Data
        
        self._companyIdentifier = data?.subdata(in: COMPANY_IDENTIFIER_RANGE).hexEncodedString()
        
        if self._companyIdentifier == COMPANY_IDENTIFIER_ESTIMOTE {
        
            self._nearableIdentifier = data?.subdata(in: BEACON_IDENTIFIER_RANGE).hexEncodedString()
            
            self._xAcceleration = hexToAcc(hexData: (data?.subdata(in: X_ACCELERATION_RANGE).hexEncodedString())!)
            self._yAcceleration = hexToAcc(hexData: (data?.subdata(in: Y_ACCELERATION_RANGE).hexEncodedString())!)
            self._zAcceleration = hexToAcc(hexData: (data?.subdata(in: Z_ACCELERATION_RANGE).hexEncodedString())!)
            
            self._durationCurrentState = hexToDur(hexData: (data?.subdata(in: DURATION_CURRENT_STATE_RANGE).hexEncodedString())!)
            self._durationPreviousSate = hexToDur(hexData: (data?.subdata(in: DURATION_PREVIOUS_STATE_RANGE).hexEncodedString())!)
            
            for unknByte in UNKNOWN_BYTES_ARRAY {
                self._unknownBytes.append((data?.subdata(in: unknByte..<unknByte+1).hexEncodedString())!)
            }
            
            self._rssi = Int(RSSI)
        }
        
        self._timeStamp = Date()
    }
    
    func wasUpdated(previousMeasurementPoint: MeasurementPoint) {
        self._count = previousMeasurementPoint.count + 1
        
        let lastfrequency = 1/self.timeStamp.timeIntervalSince(previousMeasurementPoint.timeStamp)
        
        if self._count < MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY {
            self._frequency = ((Double(previousMeasurementPoint.count)*previousMeasurementPoint.frequency!)+lastfrequency)/Double(self._count)
        } else {
            self._frequency = (((Double(MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY)-1)*previousMeasurementPoint.frequency!)+lastfrequency)/Double(MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY)
        }
        self._isSelected = previousMeasurementPoint.isSelected
    }
    
    func wasSelected() {
        if self._isSelected {
            self._isSelected = false
        } else {
            self._isSelected = true
        }
    }
    
    private func hexToAcc(hexData: String) -> Double {
        var accDec = Double(Int8(bitPattern: UInt8(strtoul(hexData, nil, 16))))/Double(CALIBRATION_ACCELERATION)
        accDec = round(accDec*100)/100
        return Double(accDec)
    }
    
    private func hexToDur(hexData: String) -> Int {
        let durDec = Int(UInt8(hexData, radix: 16)!)
        return durDec
    }
}
