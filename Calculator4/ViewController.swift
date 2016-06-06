//
//  ViewController.swift
//  Calculator4
//
//  Created by Piret Pomerants on 23/05/16.
//  Copyright © 2016 Piret Pomerants. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false

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
        } else {
            if digit == "." {
                display.text = "0."
                userIsInTheMiddleOfTypingANumber = true
            } else {
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOneArgumentOperation { sqrt($0) }
        case "sin": performOneArgumentOperation { sin($0) }
        case "cos": performOneArgumentOperation { cos($0) }
        default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOneArgumentOperation(operation: (Double) -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        history.text = "\(displayValue)"
        print("operandStack = \(operandStack)")
    }
    
    let piValue = M_PI
    
    @IBAction func pi() {
        userIsInTheMiddleOfTypingANumber = true
        if display.text != "0" {
            enter()
            display.text = "\(piValue)"
            enter()
        } else {
            display.text = "\(piValue)"
            enter()
        }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.removeAll()
        display.text = "0"
        enter()
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
}

