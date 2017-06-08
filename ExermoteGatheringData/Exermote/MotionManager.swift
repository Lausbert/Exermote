//
//  MotionManager.swift
//  Exermote
//
//  Created by Stephan Lerner on 09.03.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation
import CoreMotion

class MotionManager: NSObject {
    
    private let motionManager: CMMotionManager = CMMotionManager()
    
    override init() {
        super.init()
        motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical)
    }
    
    func currentDeviceState() -> DeviceState {
        return DeviceState(deviceMotion: motionManager.deviceMotion)
    }
}
