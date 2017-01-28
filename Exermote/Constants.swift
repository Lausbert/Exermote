//
//  Constants.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation
import UIKit

// MARK: Estimote Beacon Constants

let COMPANY_IDENTIFIER_ESTIMOTE_RANGE:Range<Int> = 0..<2
let BEACON_IDENTIFIER_RANGE:Range<Int> = 3..<11
let X_ACCELERATION_RANGE:Range<Int> = 16..<17
let Y_ACCELERATION_RANGE:Range<Int> = 17..<18
let Z_ACCELERATION_RANGE:Range<Int> = 18..<19
let DURATION_CURRENT_STATE_RANGE:Range<Int> = 19..<20
let DURATION_PREVIOUS_STATE_RANGE:Range<Int> = 20..<21
let UNKNOWN_BYTES_ARRAY = [2,11,12,13,14,15,21]

let CALIBRATION_ACCELERATION = 6.524
let MAXIMUM_MEASUREMENT_POINTS_FOR_PERIOD_AVERAGE = 10
let COMPANY_IDENTIFIER_ESTIMOTE = "5d01"

// MARK: Color Constants

let SHADOW_COLOR: CGFloat = 157.0/255.0

let MEASUREMENT_CELL_DESELECTED_COLOR = UIColor(colorLiteralRed: 178.0/255.0, green: 198.0/255.0, blue: 193.0/255.0, alpha: 1)
let MEASUREMENT_CELL_SELECTED_COLOR = UIColor(colorLiteralRed: 175.0/255.0, green: 163.0/255.0, blue: 118.0/255.0, alpha: 1)

// MARK: UI Constants

let MAXIMUM_TIME_SINCE_UPDATE_BEFORE_DISAPPEARING = 30.0
let MAXIMUM_UI_UPDATE_FREQUENCY = 5.0
