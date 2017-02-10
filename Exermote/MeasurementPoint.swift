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
    private var _unknownBytes = [String]()
    private var _count = 0
    private var _isSelected = false
    
    private var _nearableIdentifier: String?
    private var _frequency: Double?
    private var _rssi: Int?
    private var _xAcceleration: Double?
    private var _yAcceleration: Double?
    private var _zAcceleration: Double?
    private var _durationCurrentState: Int?
    private var _durationPreviousSate: Int?
    private var _timeStamp: Date!
    
    var companyIdentifier: String {
        guard _companyIdentifier != nil else {return ERROR_VALUE_STRING}
        return _companyIdentifier!
    }
    
    var count: Int {
        return _count
    }
    
    var isSelected: Bool {
        return _isSelected
    }
    
    var nearableIdentifier: String {
        guard _nearableIdentifier != nil else {return ERROR_VALUE_STRING}
        return _nearableIdentifier!
    }
    
    var frequency: String {
        guard _frequency != nil else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", _frequency!)
    }
    
    var rssi: String {
        guard _rssi != nil else {return ERROR_VALUE_STRING}
        return String(_rssi!)
    }
    
    var xAcceleration: String {
        guard _xAcceleration != nil else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", _xAcceleration!)
    }
    
    var yAcceleration: String {
        guard _yAcceleration != nil else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", _yAcceleration!)
    }
    
    var zAcceleration: String {
        guard _zAcceleration != nil else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", _zAcceleration!)
    }
    
    var durationCurrentState: String {
        guard _durationCurrentState != nil else {return ERROR_VALUE_STRING}
        return String(_durationCurrentState!)
    }
    
    var durationPreviousState: String {
        guard _durationPreviousSate != nil else {return ERROR_VALUE_STRING}
        return String(_durationPreviousSate!)
    }
    
    var timeStamp: Date {
        return _timeStamp
    }
    
    var toStringDictionary: Dictionary<String, String> {
        
        var dict = [String : String]()
        
        dict[USER_DEFAULTS_RECORDED_DATA[0]] = nearableIdentifier
        dict[USER_DEFAULTS_RECORDED_DATA[1]] = frequency
        dict[USER_DEFAULTS_RECORDED_DATA[2]] = rssi
        dict[USER_DEFAULTS_RECORDED_DATA[3]] = xAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA[4]] = yAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA[5]] = zAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA[6]] = durationCurrentState
        dict[USER_DEFAULTS_RECORDED_DATA[7]] = durationPreviousState
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd HH:mm:ss:SSS"
        dict[USER_DEFAULTS_RECORDED_DATA[8]] = dateFormatter.string(from: timeStamp)
        
        return dict
    }
    
    init?(advertisementData: [String : Any], RSSI: NSNumber) {
        
        let data = advertisementData["kCBAdvDataManufacturerData"] as? Data
        
        self._companyIdentifier = data?.subdata(in: COMPANY_IDENTIFIER_RANGE).hexEncodedString()
        
        guard self._companyIdentifier == COMPANY_IDENTIFIER_ESTIMOTE else {return nil}
            
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
        
        
        self._timeStamp = Date()
    }
    
    func update(previousMeasurementPoint: MeasurementPoint) {
        
        self._count = previousMeasurementPoint.count + 1
        
        let previousFrequency = previousMeasurementPoint.frequency == ERROR_VALUE_STRING ? 0 : Double(previousMeasurementPoint.frequency)
        let lastfrequency = 1/self.timeStamp.timeIntervalSince(previousMeasurementPoint.timeStamp)
        
        if self._count < MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY {
            self._frequency = (((Double(previousMeasurementPoint._count)-1)*previousFrequency!)+lastfrequency)/Double(self._count)
        } else {
            self._frequency = (((Double(MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY)-1)*previousFrequency!)+lastfrequency)/Double(MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY)
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
        let randomNumber = drand48()/10
        var accDec = Double(Int8(bitPattern: UInt8(strtoul(hexData, nil, 16))))/Double(CALIBRATION_ACCELERATION) + randomNumber
        accDec = round(accDec*100)/100
        return Double(accDec)
    }
    
    private func hexToDur(hexData: String) -> Int {
        let durDec = Int(UInt8(hexData, radix: 16)!)
        return durDec
    }
}
