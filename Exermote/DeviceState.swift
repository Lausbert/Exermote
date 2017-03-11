//
//  File.swift
//  Exermote
//
//  Created by Stephan Lerner on 11.03.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation
import CoreMotion

class DeviceState {
    
    private var _xGravity: Double?
    private var _yGravity: Double?
    private var _zGravity: Double?
    private var _xAcceleration: Double?
    private var _yAcceleration: Double?
    private var _zAcceleration: Double?
    private var _pitch: Double?
    private var _roll: Double?
    private var _yaw: Double?
    private var _xRotationRate: Double?
    private var _yRotationRate: Double?
    private var _zRotationRate: Double?
    
    init(deviceMotion: CMDeviceMotion?) {
        _xGravity = deviceMotion?.gravity.x
        _yGravity = deviceMotion?.gravity.y
        _zGravity = deviceMotion?.gravity.z
        _xAcceleration = deviceMotion?.userAcceleration.x
        _yAcceleration = deviceMotion?.userAcceleration.y
        _zAcceleration = deviceMotion?.userAcceleration.z
        _pitch = deviceMotion?.attitude.pitch
        _roll = deviceMotion?.attitude.roll
        _yaw = deviceMotion?.attitude.yaw
        _xRotationRate = deviceMotion?.rotationRate.x
        _yRotationRate = deviceMotion?.rotationRate.y
        _zRotationRate = deviceMotion?.rotationRate.z
    }
    
    var xGravity: String {
        guard let result = _xGravity else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var yGravity: String {
        guard let result = _yGravity else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var zGravity: String {
        guard let result = _zGravity else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
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
    
    var pitch: String {
        guard let result = _pitch else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var roll: String {
        guard let result = _roll else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var yaw: String {
        guard let result = _yaw else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var xRotationRate: String {
        guard let result = _xRotationRate else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var yRotationRate: String {
        guard let result = _yRotationRate else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var zRotationRate: String {
        guard let result = _zRotationRate else {return ERROR_VALUE_STRING}
        return String(format: "%.2f", result)
    }
    
    var stringDictionary: Dictionary<String, String> {
        
        var dict = [String : String]()
        
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[0]] = xGravity
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[1]] = yGravity
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[2]] = zGravity
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[3]] = xAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[4]] = yAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[5]] = zAcceleration
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[6]] = pitch
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[7]] = roll
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[8]] = yaw
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[9]] = xRotationRate
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[10]] = yRotationRate
        dict[USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE[11]] = zRotationRate
        
        return dict
    }
}
