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

        tlSquare.addPieChart(withPercentage: 0)
        trSquare.addPieChart(withPercentage: 0)
        blSquare.addPieChart(withPercentage: 0)
        brSquare.addPieChart(withPercentage: 0)
        
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
        
        if let steps = viewModel.todaysSteps {
            tlSquare.addPieChart(withPercentage: getPercentage(value: steps, total: viewModel.targetSteps!))
            tlSquare.amountLabel.text = String(steps)
        }
        
        if let time = viewModel.todaysTime {
            trSquare.addPieChart(withPercentage: getPercentage(value: time, total: viewModel.targetTime!))
            trSquare.amountLabel.text = String(time)
        }
        
        if let distance = viewModel.todaysDistance {
            blSquare.addPieChart(withPercentage: getPercentage(value: distance, total: viewModel.targetDistance!))
            blSquare.amountLabel.text = String(distance)
        }
        
        if let calories = viewModel.todaysCalories {
            brSquare.addPieChart(withPercentage: getPercentage(value: calories, total: viewModel.targetCalories!))
            brSquare.amountLabel.text = String(calories)
        }
        
        tlSquare.hideActivityView()
        trSquare.hideActivityView()
        brSquare.hideActivityView()
        blSquare.hideActivityView()
    }
    
    func getPercentage(value:Int, total:Int) -> Int {
        let percentage:Float = (Float(value) / Float(total)) * 100.0
        return Int(percentage)
    }

    @IBAction func syncButtonAction(_ sender: Any) {
        activityView.startAnimating()
        activityView.isHidden = false
        
        viewModel.connectToPedometer()
        
        tlSquare.showActivityView()
        trSquare.showActivityView()
        blSquare.showActivityView()
        brSquare.showActivityView()

    }
    @IBAction func challengeButtonAction(_ sender: Any) {
        trSquare.addPieChart(withPercentage: 20)
        blSquare.addPieChart(withPercentage: 30)
        brSquare.addPieChart(withPercentage: 40)
    }
    @IBAction func messageButtonAction(_ sender: Any) {
    }
    @IBAction func fundraisingButtonAction(_ sender: Any) {
    }
}