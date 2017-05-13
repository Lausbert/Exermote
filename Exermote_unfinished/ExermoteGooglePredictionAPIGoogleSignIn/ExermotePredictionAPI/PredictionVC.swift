//
//  PredictionVC.swift
//  ExermotePredictionAPI
//
//  Created by Stephan Lerner on 14.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class PredictionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var accessToken: String?
        
        GIDSignIn.sharedInstance().currentUser.authentication.getTokensWithHandler { (authentication, error) in
            
            if let err = error {
                print(err)
            } else {
                if let auth = authentication {
                    accessToken = auth.accessToken
                }
            }
        }
        
        if let accTok = accessToken {
            
            let parameters = [
                "input": [
                    "csvInstance": [
                        0.9,
                        0.14,
                        -0.41,
                        1.61,
                        -1.67,
                        1.57,
                        -0.14,
                        1.15,
                        0.26,
                        -1.52,
                        -1.57,
                        3.65
                    ]
                    
                ]
            ]
            
            let url = NSURL(string: "https://www.googleapis.com/prediction/v1.6/projects/ExermotePredictionAPI/trainedmodels/getExercise/predict")
            
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(accTok)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                        print(json)
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
            })
            
            task.resume()
        }
    }
}
