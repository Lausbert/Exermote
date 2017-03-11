//
//  MeasurementPoint.swift
//  Exermote
//
//  Created by Stephan Lerner on 05.03.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class MeasurementPoint {
    
    private var _iBeaconStates: [IBeaconState]
    private var _metaData: MetaData
    private var _timeStampSaved: Date
    
    var timeStampSaved: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd HH:mm:ss:SSS"
        return dateFormatter.string(from: _timeStampSaved)
    }
    
    init(iBeaconStates: [IBeaconState], metaData: MetaData) {
        _iBeaconStates = iBeaconStates
        _metaData = metaData
        _timeStampSaved = Date()
    }
    
    class func CSVHeaderString() -> String {
        
        var headerData: [String] = []
        
        let selectedBeacons = BLEManager.instance.iBeaconStates.filter{$0.isSelected}
        
        for beacon in selectedBeacons {
            for key in USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE {
                
                if UserDefaults.standard.bool(forKey: key) {
                    var data: String = key
                    if let text = UserDefaults.standard.string(forKey: beacon.nearableIdentifier) {
                        data = text + ": " + data
                    }
                    headerData.append(data)
                }
                
            }
        }
        
        for key in USER_DEFAULTS_RECORDED_DATA_META_DATA {
            if UserDefaults.standard.bool(forKey: key) {
                headerData.append(key)
            }
        }
        
        headerData.append("timeStampSaved")
        
        return headerData.joined(separator: CSV_DELIMETER) + CSV_LINE_BREAK
    }
    
    func CSVDataString() -> String {
        
        var data: [String] = []
        
        for iBeaconState in _iBeaconStates {
            
            let iBeaconStateDictionary = iBeaconState.stringDictionary
            
            for key in USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE {
                if UserDefaults.standard.bool(forKey: key) {
                    data.append(iBeaconStateDictionary[key]!)
                }
            }
        }
        
        let metaDataDictionary = _metaData.stringDictionary
        
        for key in USER_DEFAULTS_RECORDED_DATA_META_DATA {
            if UserDefaults.standard.bool(forKey: key) {
                data.append(metaDataDictionary[key]!)
            }
        }
        
        data.append(timeStampSaved)
        
        return data.joined(separator: CSV_DELIMETER) + CSV_LINE_BREAK
    }
}
