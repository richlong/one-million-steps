//
//  EnterUserDetailsViewController.swift
//  OneMillionSteps
//
//  Created by Rich Long on 29/11/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit
import SwiftValidator

class EnterUserDetailsViewController: UIViewController, ValidationDelegate, UITextFieldDelegate {
    
    let viewModel = EnterUserDetailsViewModel()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var weightError: UILabel!
    @IBOutlet weak var heightError: UILabel!
    var isMetric = false

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var unitSelector: UISegmentedControl!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var heightInchesTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var weightPoundTextField: UITextField!
    
    @IBOutlet weak var viewTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightTexFieldWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weightTextFieldWidthConstraint: NSLayoutConstraint!
    let validator = Validator()
    var textFieldArray = [UITextField]()
    var errorLabelArray = [UILabel]()
    var textFieldInitialWidth:CGFloat = 100
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EnterUserDetailsViewController.dataSaved(notification:)), name: NSNotification.Name(rawValue: "userDetailsSaved"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EnterUserDetailsViewController.keyboardWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EnterUserDetailsViewController.keyboardWillDisappear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        textFieldArray.append(contentsOf: [heightTextField,weightTextField,heightInchesTextField,weightPoundTextField])
//        errorLabelArray.append(contentsOf: [weightError,heightError])
        textFieldInitialWidth = heightTexFieldWidthConstraint.constant
        showMetric()
        unitSelector.selectedSegmentIndex = 1
        datePicker.maximumDate = Date()

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EnterUserDetailsViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func keyboardWillAppear(notification: NSNotification){
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            toggleKeyboard(position: CGFloat(0 - keyboardSize.height))
//        }
    }
    
    func keyboardWillDisappear(notification: NSNotification){
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            toggleKeyboard(position: CGFloat(keyboardSize.height))
//        }
    }
    
    func toggleKeyboard(position:CGFloat) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.viewTopLayoutConstraint.constant += position
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
        }
        

    }
    
    func addValidation(rule:RegexRule) {
        for textField in textFieldArray {
            validator.unregisterField(textField)
            textField.delegate = self
        }
        
        if isMetric {
            validator.registerField(heightTextField, rules: [rule])
            validator.registerField(weightTextField, rules: [rule])
        }
        else {
            for textField in textFieldArray {
                validator.registerField(textField, rules: [rule])
            }
        }
   
    }
    func showMetric() {
        isMetric = true
        heightTextField.placeholder = "Meters e.g. 1.70"
        weightTextField.placeholder = "Kilograms e.g. 75.5"
        
        let regexRule = RegexRule(regex: "\\d{1,}\\.\\d{1,}", message: "Enter valid value")
        addValidation(rule: regexRule)
        let width = self.view.frame.width - 40
        animateTextView(newWidth: width)
    }
    
    func showImperial() {
        isMetric = false
        heightTextField.placeholder = "Feet"
        weightTextField.placeholder = "Stone"
        
        let regexRule = RegexRule(regex: "\\d{1,}", message: "Enter valid value")
        addValidation(rule: regexRule)
        animateTextView(newWidth: self.textFieldInitialWidth)
    }
    
    func animateTextView(newWidth:CGFloat) {
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.heightTexFieldWidthConstraint.constant = newWidth;
            self.weightTextFieldWidthConstraint.constant = newWidth;
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
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
        nextView()
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        resetTextFields()
        validator.validate(self)
    }
    
    func validationSuccessful() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMYY"

        let date = dateFormatter.string(from: datePicker.date)
        let today = dateFormatter.string(from: Date())

        if date != today {
            viewModel.date = datePicker.date
        }
        
        if isMetric {
            viewModel.meters = Float(heightTextField.text!)
            viewModel.kg = Float(weightTextField.text!)
            viewModel.isMetric = true
        }
        else {
            viewModel.feet = Int(heightTextField.text!)
            viewModel.inches = Int(heightInchesTextField.text!)
            viewModel.stones = Int(weightTextField.text!)
            viewModel.pounds = Int(weightPoundTextField.text!)
            viewModel.isMetric = false
        }
        
        viewModel.saveUseDetails()
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

    func dataSaved(notification: NSNotification){
        nextView()
    }
    
    func nextView() {
        self.performSegue(withIdentifier: "nextView", sender: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


}



