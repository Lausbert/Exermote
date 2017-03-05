//
//  MetaData.swift
//  Exermote
//
//  Created by Stephan Lerner on 05.03.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class META_DATA {
    
    private var _exerciseType: String
    private var _exerciseSubType: String
    
    init(exerciseType: String, exerciseSubType: String) {
        _exerciseType = exerciseType
        _exerciseSubType = exerciseSubType
    }
    
    var stringDictionary: Dictionary<String,String> {
        
        var dict = [String : String]()
        
        dict[USER_DEFAULTS_RECORDED_DATA_META_DATA[0]] = _exerciseType
        dict[USER_DEFAULTS_RECORDED_DATA_META_DATA[1]] = _exerciseSubType
        
        return dict
    }
    
}
