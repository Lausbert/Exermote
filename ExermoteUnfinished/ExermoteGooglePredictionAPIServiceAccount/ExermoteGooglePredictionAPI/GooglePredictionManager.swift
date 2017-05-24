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
            "iss":"googlepredictionmanager@exermotepredictionapi.iam.gserviceaccount.com",
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
        
        var privateKey: String?
        
        if let path = Bundle.main.path(forResource: "ExermotePredictionAPI-266a0497ceb8", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String:String]
                privateKey = dictionary?["private_key"]
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    
        do {
            let clearMessage = try ClearMessage(string: JWTunsigned, using: .utf8)
            let privateKeyObject = try PrivateKey(pemEncoded: privateKey!)
            let signature = try clearMessage.signed(with: privateKeyObject, digestType: .sha256)
            return signature.base64String
        }
    }
}
