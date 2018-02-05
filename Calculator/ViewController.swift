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
    @IBOutlet weak var displayM: UILabel!
    
    @IBOutlet weak var tochka: UIButton!{
        didSet {
            tochka.setTitle(decimalSeparator, for: UIControlState())
        }
    }
    
    let decimalSeparator = NumberFormatter().decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTyping = false
    
    var displayValue: Double? {
        get {
            if let text = display.text, let value = formatter.number(from: text) as? Double {   //Double(text) {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.string(from: NSNumber(value: value))
            }
        }
    }
    
    var displayResult: (result: Double?, isPending: Bool, description: String, error: String?) = (nil, false, " ", nil) {
        // Наблюдатель Свойства модифицирует три IBOutlet метки
        didSet {
            switch displayResult {
            case (nil, _, " ", nil):
                displayValue = 0
            case (let result, _, _, nil):
                displayValue = result
            case (_, _, _, let error):
                display.text = error!
            }
            history.text = displayResult.description != " " ? displayResult.description + (displayResult.isPending ? " ..." : " =") : " "
            displayM.text = formatter.string(from: NSNumber(value: variableValues["M"] ?? 0))
        }
    }
    
    private var brain = CalculatorBrain()
    private var variableValues = [String: Double]()
    
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
            if digit == decimalSeparator {
                display.text = "0" + digit
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
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
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).dropFirst())
        variableValues[symbol] = displayValue
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableValues)
    }
    
    
    @IBAction func clearAll(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        variableValues = [:]
        displayResult = brain.evaluate()
        //displayValue = 0
        //history.text = " "
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if  userIsInTheMiddleOfTyping {
            guard !display.text!.isEmpty else { return }
            display.text =  String(display.text!.dropLast())
            if display.text!.isEmpty {
                userIsInTheMiddleOfTyping = false
                displayResult = brain.evaluate(using: variableValues)
                //    displayValue = 0
                //  history.text = " "
            }
        } else {
            brain.undo()
            displayResult = brain.evaluate(using: variableValues)
        }
    }
}
