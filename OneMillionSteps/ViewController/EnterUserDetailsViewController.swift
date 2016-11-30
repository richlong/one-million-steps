//
//  EnterUserDetailsViewController.swift
//  OneMillionSteps
//
//  Created by Rich Long on 29/11/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit
import SwiftValidator

class EnterUserDetailsViewController: UIViewController, ValidationDelegate {
    
    @IBOutlet weak var weightError: UILabel!
    @IBOutlet weak var heightError: UILabel!
    var isImperial = true

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var unitSelector: UISegmentedControl!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var heightInchesTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var weightPoundTextField: UITextField!
    
    @IBOutlet weak var heightTexFieldWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weightTextFieldWidthConstraint: NSLayoutConstraint!
    let validator = Validator()
    var textFieldArray = [UITextField]()
    var errorLabelArray = [UILabel]()
    var textFieldInitialWidth:CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldArray.append(contentsOf: [heightTextField,weightTextField,heightInchesTextField,weightPoundTextField])
        errorLabelArray.append(contentsOf: [weightError,heightError])
        
        let regexRule = RegexRule(regex: "\\d{1,}", message: "Enter valid value")
        validator.registerField(heightTextField, errorLabel: heightError, rules: [regexRule])
        validator.registerField(weightTextField, errorLabel: weightError, rules: [regexRule])

        showImperial()
        
        textFieldInitialWidth = heightTexFieldWidthConstraint.constant
    }
    
    func showMetric() {
        isImperial = false
        heightTextField.placeholder = "Meters"
        weightTextField.placeholder = "Kilograms"
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            
            let width = self.view.frame.width - 40
            self.heightTexFieldWidthConstraint.constant = width;
            self.weightTextFieldWidthConstraint.constant = width;

            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            print("done")
        }


    }
    
    func showImperial() {
        isImperial = true
        heightTextField.placeholder = "Feet"
        weightTextField.placeholder = "Stone"

        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.heightTexFieldWidthConstraint.constant = self.textFieldInitialWidth;
            self.weightTextFieldWidthConstraint.constant = self.textFieldInitialWidth;
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            print("done")
        }

    }
    
    @IBAction func changeMeasurementSystem(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showImperial()
            break
            
        case 1:
            showMetric()
            break
            
        default:
            showImperial()
            break
        }
        
    }
    
    func resetTextFields() {
        
        for textField in textFieldArray {
            textField.layer.borderWidth = 0.0
        }
        
        for label in errorLabelArray {
            label.isHidden = true
        }
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        resetTextFields()
        validator.validate(self)
    }
    
    func nextView() {
        self.performSegue(withIdentifier: "nextVie", sender: nil)
    }
    
    func validationSuccessful() {
        // submit the form
        print("successful val")
        
        if isImperial {
            let feet = heightTextField.text
            let inches = heightInchesTextField.text
        }
        else {
            let meters = heightTextField.text
        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }

    
}



