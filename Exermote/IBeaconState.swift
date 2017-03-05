//
//  MeasurmentPoint.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.


import Foundation
import CoreBluetooth

class IBeaconState {
    
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
    private var _timeStampRecorded: Date!
    
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
        guard let result = _nearableIdentifier else {return ERROR_VALUE_STRING}
        return result
    }
    
    var frequency: String {
        guard let result = _frequency else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var frequencyAsDouble: Double? {
        guard let result = _frequency else {return 0.0}
        return result
    }
    
    var rssi: String {
        guard let result = _rssi else {return ERROR_VALUE_STRING}
        return String(result)
    }
    
    var xAcceleration: String {
        guard let result = _xAcceleration else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var yAcceleration: String {
        guard let result = _yAcceleration else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var zAcceleration: String {
        guard let result = _zAcceleration else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var durationCurrentState: String {
        guard  let result = _durationCurrentState else {return ERROR_VALUE_STRING}
        return String(result)
    }
    
    var durationPreviousState: String {
        guard let result = _durationPreviousSate else {return ERROR_VALUE_STRING}
        return String(result)
    }
    
    var timeStampRecorded: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd HH:mm:ss:SSS"
        return dateFormatter.string(from: _timeStampRecorded)
    }
    
    var timeStampRecordedAsDate: Date {
        return _timeStampRecorded
    }
    
    var stringDictionary: Dictionary<String, String> {
        
        var dict = [String : String]()
        
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[0]] = nearableIdentifier
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[1]] = frequency
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[2]] = rssi
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[3]] = xAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[4]] = yAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[5]] = zAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[6]] = durationCurrentState
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[7]] = durationPreviousState
        dict[USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE[8]] = timeStampRecorded
        
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
        
        
        self._timeStampRecorded = Date()
    }
    
    func update(previousIBeaconState: IBeaconState) {
        
        self._count = previousIBeaconState.count + 1
        
        let previousFrequency = previousIBeaconState.frequencyAsDouble
        let lastfrequency = 1/self._timeStampRecorded.timeIntervalSince(previousIBeaconState.timeStampRecordedAsDate)
        
        if self._count < MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY {
            self._frequency = (((Double(previousIBeaconState._count)-1)*previousFrequency!)+lastfrequency)/Double(self._count)
        } else {
            self._frequency = (((Double(MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY)-1)*previousFrequency!)+lastfrequency)/Double(MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY)
        }
        self._isSelected = previousIBeaconState.isSelected
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
