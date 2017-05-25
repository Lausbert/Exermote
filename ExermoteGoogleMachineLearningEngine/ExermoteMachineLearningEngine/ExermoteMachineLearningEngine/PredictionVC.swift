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
        
        let predictionManager = PredictionManager()
        predictionManager.startPrediction()
    }
}
