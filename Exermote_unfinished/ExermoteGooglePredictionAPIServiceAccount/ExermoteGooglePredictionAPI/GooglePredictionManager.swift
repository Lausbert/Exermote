//
//  GooglePredictionAPI.swift
//  ExermoteGooglePredictionAPI
//
//  Created by Stephan Lerner on 08.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import SwiftyRSA

class GooglePredictionManager {
    
    static let instance = GooglePredictionManager()
    
    init() {
        
        do {
            try getAccessToken()
        } catch {
            print(error)
        }
        
    }
    
    func getAccessToken() throws {
        
        do {
            let (JWTHeaderEncodedString, JWTClaimSetEncodedString) = try formingJWTHeaderAndClaimSet()
            let signatureEncodedString = try getSHA256SignatureWithBase64Encoding(JWTHeaderEncodedString: JWTHeaderEncodedString, JWTClaimSetEncodedString: JWTClaimSetEncodedString)
            let JWT = JWTHeaderEncodedString + "." + JWTClaimSetEncodedString + "." + signatureEncodedString
            
            let parameters: Parameters = [
                "grant_type":"urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion":JWT
            ]
            
            Alamofire.request("https://www.googleapis.com/oauth2/v4/token", method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
            }
        }
        
    }
    
    func formingJWTHeaderAndClaimSet() throws -> (String, String) {
        
        let JWTHeaderDict:[String:Any] = [
            "alg":"RS256",
            "typ":"JWT"
        ]
    
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + 3600
        
        let JWTClaimSetDict:[String:Any] = [
            "iss":"googlepredictionmanager@exermote.iam.gserviceaccount.com",
            "scope":"https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/prediction",
            "aud":"https://www.googleapis.com/oauth2/v4/token",
            "exp":exp,
            "iat":iat
        ]
        
        do {
            let JWTHeaderEncodedString = try encodeDictionaryWithBase64Encoding(dict: JWTHeaderDict)
            let JWTClaimSetEncodedString = try encodeDictionaryWithBase64Encoding(dict: JWTClaimSetDict)
            return (JWTHeaderEncodedString, JWTClaimSetEncodedString)
        }
    }
    
    func encodeDictionaryWithBase64Encoding(dict: [String:Any]) throws -> String {
        
        do {
            let json = try JSONSerialization.data(withJSONObject: dict, options: [])
            let jsonUTF8 = String(data: json, encoding: .utf8)
            let jsonBase64 = jsonUTF8?.toBase64()
            return jsonBase64!
        }
    }
    
    func getSHA256SignatureWithBase64Encoding(JWTHeaderEncodedString: String, JWTClaimSetEncodedString: String) throws -> String  {
        
        let JWTunsigned = JWTHeaderEncodedString + "." + JWTClaimSetEncodedString
        
        let test = "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDSm9uzsHb4u257\n6GEiWntLseb9cgKYNujPt725YtGXQx7EtbD6L7/L6I/aTH1w1E1gZqK6XRzIkiZm\nPBxYoOuT9K89LUzmSGaIFqwUpqPMDrOssyKxNHCf9fRHNCREKyTWMHUZ/2Rt/cMd\nTniljA572KhenaY5C0sqhdTrEQnc8xKMKwInSoxI2wg4HwbBectMp/5L3B0wsGgH\nGkFunGFKjMkOQ4VUcv+7V9BHfJLcFaSKs+/q03RHJAxijP5joMnNBEWi9s/giCvr\npEdvgoMkt6NE+6am3yRFZTFYIf7/Z5nxSW4qKdhfSjIvDrcv3qo7aCgbf7wNiVxH\nPmE2Fo9XAgMBAAECggEBALFjAu5a4CnpvEny1PVZXmXIBrVLdLH99aMWsF7Xw45y\nwxSNr+1ZkGLPk3IbYMBKoI1khQUQ7fBlYKBVWs6vYxwwR/TwFcgUDP/skK2oGWgC\nrgT0sHCuqXmhcEkUusMLz6/0Cn2GJXGa/d7OPEG7MGvRdSaUA/Ah+gJrzITcygDk\n1rSbeHiiFjhPSsAZ5fYOE5j/GGML/efRDLSfDE7vtHWp42s0Oe9eLMMmgQbEW82z\nVhBqeOjQkHVxDhr3ag6MXy5n5MDrkMbh3HVyGeV64tpHXs4M5N1iL+e3YN9aMC07\nyuZuaLsjHC/Sglla1KtDR814wQ5174p/bowOB/GyHekCgYEA94yauOdIlFiv2A3b\n9VTvYgmlNFrmo5M3AeHRkhDjQdo0+JnzT1KLfdTQ7gTFCZ66xPbiK2UzmbXFNIDc\ngf25vQ5LxrKFRqjJcocg6KcpV3KCWkONB5Sh9+FvNFIO//6LCuYM2Hvfjv5degZH\nrWFtQTQV3XgHrECwgY1iprlD7S0CgYEA2cxsEvgZ55oj8sS+MPAU2G7sNK3Cs3Z+\ndzWiGMmHJihBskamyvJOmFYkizjwUXhjcL2ZOicldQ5xqSpQe+zYeXuq405UNUuZ\n2QVQ2EezzhPSoofzrxMrwKtng3SKdTVx1qny5i0M4ZEzWgu2N466yLdTolGzWdSw\njoCIaTim6RMCgYEAnwOwt6nJ05EMk6qDapo+kylC99iUYurD4O+f4UX71WdHs5Gg\n24lYlWHJO7vQnhdaPf+g1ONTPB+pJ8rG2rGTSEAQqPgv6G2vyWPH3erTAZtK5JST\n2RS+3i3vcxprDEIEKuIPylf4CTCX9zRlgpgcyE+e4/6gXyPGvdGGVzaWzZkCgYAE\noELrZDmooa2Byov/nhnTPwflVot8JFgrUAhRXnZwaQp8LuP8C4l/0tST4HG6SURT\ncLOAeLRi+BuR7EQpXa57ZhULHu7K8wAhi+tbrKo1BlbC/QBAB7g2L23TbPZD5w6z\n8IgoO2y6ncrpbrZAF9f/y2ULXZDhp5LYdAJxubJR4QKBgFoZYEzqiEYO/MwdzrVy\n11tWGzy6NsAEGv6EBg0cIsdyg2gbzuMBsKcIrwsT9v0BTl+H4gdDALvijQOPfyJM\nQJGXamigBDjvCfMluWHzbYH/YbyRjUklhJwGQIEu12uSK8tIGd9EvR1g4ZkR4h5x\nZowPmeBkmJMQvZc0OEiP4fJb\n-----END PRIVATE KEY-----\n"
        
        do {
            let clearMessage = try ClearMessage(string: JWTunsigned, using: .utf8)
            let privateKeyObject = try PrivateKey(pemEncoded: test)
            let signature = try clearMessage.signed(with: privateKeyObject, digestType: .sha256)
            return signature.base64String
        }
    }
}
