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
    
    var userIsInTheMiddleOfTyping = false
    override func viewDidLoad() {
        let btn = UIButton()
        btn.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit != ".") || !(textCurrentlyInDisplay.contains(".")) {
            display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
       // print("\(String(describing: digit)) was touched")
        
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
        displayValue = result
        }
        if let description = brain.description {
//            if brain.resultIsPending {
//                history.text =
//            }
            history.text = description + (brain.resultIsPending ? " ..." : " =")
        }
    }
    
}
