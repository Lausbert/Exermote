//
//  Extensions.swift
//  ExermoteGooglePredictionAPI
//
//  Created by Stephan Lerner on 08.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
