//
//  ViewController.swift
//  Calculator4
//
//  Created by Piret Pomerants on 23/05/16.
//  Copyright © 2016 Piret Pomerants. All rights reserved.
//

import UIKit

extension UILabel {
    
    var value: Double? {
        get {
            return NSNumberFormatter().numberFromString(self.text!) as? Double
        }
        set {
            if newValue != nil {
                self.text = "\(newValue!)"
            } else {
                self.text = ""
            }
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            if digit == "." {
                if (display.text!.rangeOfString(".") == nil) {
                    display.text = display.text! + "."
                }
            } else {
                display.text = display.text! + digit
            }
            history.text = digit
        } else {
            if digit == "." {
                display.text = "0."
                history.text = ("0"+digit)
                userIsInTheMiddleOfTypingANumber = true
            } else {
                display.text = digit
                history.text = digit
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                display.value = result
            } else {
                display.value = 0
            }
            history.text = brain.description+"="
        }
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTypingANumber && display.value != nil {
            brain.pushOperand(display.value!)
            history.text = brain.description
        }
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func pushConstant(sender: UIButton) {
        let constant = sender.currentTitle!
        enter()
        display.text = constant
        brain.performOperation(constant)
        history.text = brain.description
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.characters.count > 1 {
                display.text = String((display.text!).characters.dropLast())
            } else {
                userIsInTheMiddleOfTypingANumber = false
                display.value = 0
            }
        }
    }
    
    @IBAction func appendSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber && display.value != nil {
            display.value = -display.value!
        } else {
            operate(sender)
        }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        display.value = 0
        history.text = " "
        brain.clearOpStack()
    }
}
