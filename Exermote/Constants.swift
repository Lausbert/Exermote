//
//  Constants.swift
//  Excermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation

let COMPANY_IDENTIFIER_ESTIMOTE_RANGE:Range<Int> = 0..<2
let BEACON_IDENTIFIER_RANGE:Range<Int> = 3..<11
let X_ACCELERATION_RANGE:Range<Int> = 16..<17
let Y_ACCELERATION_RANGE:Range<Int> = 17..<18
let Z_ACCELERATION_RANGE:Range<Int> = 18..<19
let DURATION_CURRENT_STATE_RANGE:Range<Int> = 19..<20
let DURATION_PREVIOUS_STATE_RANGE:Range<Int> = 20..<21
let UNKNOWN_BYTES_ARRAY = [2,11,12,13,14,15,21]

let CALIBRATION_ACCELERATION = 6.524

let COMPANY_IDENTIFIER_ESTIMOTE = "5d01"

func hexToAcc(hexData: String) -> Double {
    var accDec = Double(Int8(bitPattern: UInt8(strtoul(hexData, nil, 16))))/Double(CALIBRATION_ACCELERATION)
    accDec = round(accDec*100)/100
    return Double(accDec)
}

func hexToDur(hexData: String) -> Int {
    let durDec = Int(UInt8(hexData, radix: 16)!)
    return durDec
}
