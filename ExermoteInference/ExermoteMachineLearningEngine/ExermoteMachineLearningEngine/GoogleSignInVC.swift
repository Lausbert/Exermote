//
//  ViewController.swift
//  ExermoteMachineLearningEngine
//
//  Created by Stephan Lerner on 21.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class GoogleSignInVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        guard error == nil else {print(error); return}
        
        print("Successfully loggend in with \(user.profile.name)")
        DispatchQueue.main.async {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PredictionVC") as UIViewController
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

