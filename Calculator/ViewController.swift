//
//  ViewController.swift
//  Calculator
//
//  Created by Nick on 1/27/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var tochka: UIButton!{
        didSet {
            tochka.setTitle(decimalSeparator, for: UIControlState())
        }
    }
    
    let decimalSeparator = NumberFormatter().decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTyping = false
    
    
    var displayValue: Double? {
        get {
            if let text = display.text, let value = brain.formatter.number(from: text) as? Double {   //Double(text) {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = brain.formatter.string(from: NSNumber(value: value))
            }
            history.text = description + (brain.resultIsPending ? " ..." : " =")
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit == "0") && ((textCurrentlyInDisplay == "0") || (textCurrentlyInDisplay == "-0") ) {
                return
            }
            if (digit != decimalSeparator) && ((textCurrentlyInDisplay == "0") || (textCurrentlyInDisplay == "-0")) {
                display.text = digit
                return
            }
            if (digit != decimalSeparator) || !(textCurrentlyInDisplay.contains(decimalSeparator)) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
        // print("\(String(describing: digit)) was touched")
        
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let value = displayValue {
                brain.setOperand(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        if let description = brain.description {
            history.text = description + (brain.resultIsPending ? " ..." : " =")
        }
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        history.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else { return }
        display.text =  String(display.text!.dropLast())
        if display.text!.isEmpty {
            displayValue = 0
            userIsInTheMiddleOfTyping = false
        }
    }
    
}
