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

let COMPANY_IDENTIFIER_RANGE:Range<Int> = 0..<2
let BEACON_IDENTIFIER_RANGE:Range<Int> = 3..<11
let X_ACCELERATION_RANGE:Range<Int> = 16..<17
let Y_ACCELERATION_RANGE:Range<Int> = 17..<18
let Z_ACCELERATION_RANGE:Range<Int> = 18..<19
let DURATION_CURRENT_STATE_RANGE:Range<Int> = 19..<20
let DURATION_PREVIOUS_STATE_RANGE:Range<Int> = 20..<21
let UNKNOWN_BYTES_ARRAY = [2,11,12,13,14,15,21]

let CALIBRATION_ACCELERATION = 6.524
let COMPANY_IDENTIFIER_ESTIMOTE = "5d01"

// MARK: BLEManager and IBeaconState Constants

let MAXIMUM_TIME_SINCE_UPDATE_BEFORE_DISAPPEARING = 30.0
let MAXIMUM_NUMBER_FOR_CALCULATING_AVERAGE_OF_FREQUENCY = 1
let TIME_UNTIL_BLE_MANAGER_PAUSES_WITH_SCANNING = 2.0
let TIME_OF_SCANNING_PAUSE_FOR_BLE_MANAGER = 0.1

// MARK: Recording Constants

let RECORDING_DURATION_MAXIMUM = 5
let RECORDING_DURATION_MINIMUM = 1
let RECORDING_FREQUENCY_INITIAL = 10
let RECORDING_FREQUENCY_OPTIONS = [1,5,10]

// MARK: Color Constants

let COLOR_SHADOW = UIColor(colorLiteralRed: 157.0/255.0, green: 157.0/255.0, blue: 157.0/255.0, alpha: 0.5).cgColor
let COLOR_NOT_HIGHLIGHTED = UIColor(colorLiteralRed: 178.0/255.0, green: 198.0/255.0, blue: 193.0/255.0, alpha: 1)
let COLOR_HIGHLIGHTED = UIColor(colorLiteralRed: 175.0/255.0, green: 163.0/255.0, blue: 118.0/255.0, alpha: 1)

// MARK: UI Constants

let UI_MAXIMUM_UPDATE_FREQUENCY = 5.0

// MARK: Segues, Storyboard and Transition Constants

let SEGUE_SET_SETTINGS = "setSettings"
let SEGUE_RECORDING_WORKOUT = "recordingWorkout"
let SEGUE_MANAGE_EXERCISE = "manageExercise"
let SEGUE_EDIT_EXERCISE = "editExercise"
let STORYBOARD_ID_RECORDING_WORKOUT_VC = "recordingWorkoutVC"
let STORYBOARD_ID_SET_SETTINGS_VC = "setSettingsVC"
let STORYBAORD_ID_SELECT_NEARABLES_VC = "selectNearablesVC"
let STORYBOARD_ID_MANAGE_EXERCISE_VC = "manageExerciseVC"
let STORYBOARD_ID_EDIT_EXERCISE_VC = "editExerciseVC"
let TRANSITION_TYPE = kCATransitionMoveIn
let TRANSITION_DURATION = 0.5

// MARK: User Defaults Constants

let USER_DEFAULTS_RECORDING_DURATION = "recordingDuration"
let USER_DEFAULTS_RECORDING_FREQUENCY = "recordingFrequency"
let USER_DEFAULTS_RECORDED_DATA = ["nearableID",
                                   "frequency",
                                   "rssi",
                                   "xAcceleration",
                                   "yAcceleration",
                                   "zAcceleration",
                                   "currentStateDuration",
                                   "previousStateDuration",
                                   "timeStampRecorded"]

let USER_DEFAULTS_SHOW_FREQUENCY_ALERT = "frequencyAlertWasShown"
let USER_DEFAULTS_SHOW_ICLOUD_ALERT = "iCloudAlertWasShown"

let USER_DEFAULTS_EXERCISES = "exercises"

// MARK: Error Value Constants

let ERROR_VALUE_STRING = "NA"

// MARK: Notification Constants

let NOTIFICATION_BLE_MANAGER_NEW_PERIPHERALS = "newPeripherals"
let NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED = "recordingStopped"
let NOTIFICATION_RECORDING_MANAGER_SWIFT_SPINNER_UPDATE_NEEDED = "swiftSpinnerUpdateNeeded"

// MARK: CSV Constants

let CSV_DELIMETER = ","
let CSV_LINE_BREAK = "\n"

// MARK: Exercise Constants

let EXERCISE_ATTRIBUTES = ["name",
                           "includedInWorkout",
                           "maximumDuration",
                           "minimumDuration",
                           "firstHalfSecondHalfRatio",
                           "repetitionBreakDuration",
                           "setBreakDuration",
                           "exerciseBreakDuration"]
