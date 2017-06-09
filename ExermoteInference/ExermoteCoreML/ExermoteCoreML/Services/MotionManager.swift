//
//  MotionManager.swift
//  ExermoteCoreML
//
//  Created by Stephan Lerner on 09.06.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation
import CoreMotion

class MotionManager {
    
    private let motionManager: CMMotionManager = CMMotionManager()
    
    init() {
        motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical)
    }
    
    var currentRawMotionArray: [Double] {
        return [xGravity,
                yGravity,
                zGravity,
                xAcceleration,
                yAcceleration,
                zAcceleration,
                pitch,
                roll,
                yaw,
                xRotationRate,
                yRotationRate,
                zRotationRate
        ]
    }
    
    private var xGravity: Double {
        guard let result = motionManager.deviceMotion?.gravity.x else {return 0.0}
        return result
    }
    
    private var yGravity: Double {
        guard let result = motionManager.deviceMotion?.gravity.y else {return 0.0}
        return result
    }
    
    private var zGravity: Double {
        guard let result = motionManager.deviceMotion?.gravity.z else {return 0.0}
        return result
    }
    
    private var xAcceleration: Double {
        guard let result = motionManager.deviceMotion?.userAcceleration.x else {return 0.0}
        return result
    }
    
    private var yAcceleration: Double {
        guard let result = motionManager.deviceMotion?.userAcceleration.y else {return 0.0}
        return result
    }
    
    private var zAcceleration: Double {
        guard let result = motionManager.deviceMotion?.userAcceleration.z else {return 0.0}
        return result
    }
    
    private var pitch: Double {
        guard let result = motionManager.deviceMotion?.attitude.pitch else {return 0.0}
        return result
    }
    
    private var roll: Double {
        guard let result = motionManager.deviceMotion?.attitude.roll else {return 0.0}
        return result
    }
    
    private var yaw: Double {
        guard let result = motionManager.deviceMotion?.attitude.yaw else {return 0.0}
        return result
    }
    
    private var xRotationRate: Double {
        guard let result = motionManager.deviceMotion?.rotationRate.x else {return 0.0}
        return result
    }
    
    private var yRotationRate: Double {
        guard let result = motionManager.deviceMotion?.rotationRate.y else {return 0.0}
        return result
    }
    
    private var zRotationRate: Double {
        guard let result = motionManager.deviceMotion?.rotationRate.z else {return 0.0}
        return result
    }
    
}

