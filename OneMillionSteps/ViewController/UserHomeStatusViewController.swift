//
//  UserHomeStatusViewController.swift
//  OneMillionSteps
//
//  Created by Rich Long on 02/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit

class UserHomeStatusViewController: UIViewController {
    @IBOutlet weak var tlSquare: StatusSquare!
    @IBOutlet weak var trSquare: StatusSquare!
    @IBOutlet weak var blSquare: StatusSquare!
    @IBOutlet weak var brSquare: StatusSquare!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var fundraisingButton: UIButton!
    
    let viewModel = UserHomeStatusViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trSquare.titleLabel.textAlignment = .right
        brSquare.titleLabel.textAlignment = .right

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserHomeStatusViewController.stepsRecieved(notification:)), name: Notification.Name("bluetoothStepsReturned"), object: nil)

//        tlSquare.addPieChart(withPercentage: 50)
//        trSquare.addPieChart(withPercentage: 50)
        blSquare.addPieChart(withPercentage: 50)
//        brSquare.addPieChart(withPercentage: 50)
        
        tlSquare.titleLabel.text = "STEPS"
        trSquare.titleLabel.text = "ACTIVE MINUTES"
        blSquare.titleLabel.text = "DISTANCE"
        brSquare.titleLabel.text = "CALORIES BURNED"

        tlSquare.amountLabel.text = "-"
        trSquare.amountLabel.text = "-"
        blSquare.amountLabel.text = "-"
        brSquare.amountLabel.text = "-"
        
    }
    
    func stepsRecieved(notification: NSNotification){
        activityView.isHidden = true
        tlSquare.amountLabel.text = String(viewModel.todaysSteps)
        
        if viewModel.targetSteps > 0 {
            let percentage:Int = (viewModel.todaysSteps / viewModel.targetSteps) * 100
            tlSquare.addPieChart(withPercentage: percentage)
        }
    }

    @IBAction func syncButtonAction(_ sender: Any) {
        activityView.startAnimating()
        activityView.isHidden = false
        viewModel.connectToPedometer()
        
        tlSquare.addPieChart(withPercentage: 75)

    }
    @IBAction func challengeButtonAction(_ sender: Any) {
        
        tlSquare.addPieChart(withPercentage: 25)
        trSquare.addPieChart(withPercentage: 10)

    }
    @IBAction func messageButtonAction(_ sender: Any) {
        brSquare.addPieChart(withPercentage: 90)

    }
    @IBAction func fundraisingButtonAction(_ sender: Any) {
    }
}
