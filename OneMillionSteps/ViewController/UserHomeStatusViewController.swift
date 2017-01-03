//
//  UserHomeStatusViewController.swift
//  OneMillionSteps
//
//  Created by Rich Long on 02/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift
import Toast_Swift

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
        
        navigationController?.navigationBar.topItem?.title = "One Million Steps"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserHomeStatusViewController.stepsRecieved(notification:)), name: Notification.Name("bluetoothStepsReturned"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserHomeStatusViewController.bluetoothError(notification:)), name: Notification.Name("bluetoothError"), object: nil)

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
        
        trSquare.iconLabel.fa_text = .fa_clock_o
        trSquare.iconLabel.font = UIFont(fa_fontSize: 50)
        
        blSquare.iconLabel.fa_text = .fa_arrows_h
        blSquare.iconLabel.font = UIFont(fa_fontSize: 50)

        brSquare.iconLabel.fa_text = .fa_fire
        brSquare.iconLabel.font = UIFont(fa_fontSize: 50)
        
        styleButton()

    }
    
    func styleButton() {
        syncButton.layer.cornerRadius = 0.5 * syncButton.bounds.size.width
        syncButton.clipsToBounds = true
        syncButton.fa_setTitle(.fa_refresh, for: .normal)
        syncButton.titleLabel?.font = UIFont(fa_fontSize: 40)
    }
    
    func bluetoothError(notification: NSNotification){
        self.view.makeToast("Unable to connect to pedometer", duration: 5.0, position: .top)
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
