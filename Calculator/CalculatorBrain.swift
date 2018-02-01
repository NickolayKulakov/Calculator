//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Nick on 1/29/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.notANumberSymbol = "Error"
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter
    } ()
    
    
    private var accumulator: Double?
    private var descriptionAccumulator: String?
   
    var description: String? {
        get {
            if pendingBinaryOperation == nil {
                return descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, descriptionAccumulator ?? "")
            }
        }
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    private enum Operation {
        case nullaryOperation (() -> Double, String)
        case constant(Double)
        case unaryOperation((Double) -> Double, ((String) -> String)?)
        case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?)
        case equals
    }
    
    private var operations: Dictionary <String, Operation> = [
        "Ran": Operation.nullaryOperation({Double(arc4random()) / Double(UInt32.max)}, "rand()"),
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "±": Operation.unaryOperation({ -$0 }, nil),         //{"±(" + $0 + ")"}
        "√": Operation.unaryOperation(sqrt, nil),            //{"√(" + $0 + ")"}
        "cos": Operation.unaryOperation(cos, nil),           //{"cos(" + $0 + ")"}
        "sin": Operation.unaryOperation(sin, nil),           //{"sin(" + $0 + ")"}
        "tan": Operation.unaryOperation(tan, nil),           //{"tan(" + $0 + ")"}
        "sin⁻¹": Operation.unaryOperation(asin, nil),        //{"sin⁻¹(" + $0 + ")"}
        "cos⁻¹": Operation.unaryOperation(acos, nil),        //{"cos⁻¹(" + $0 + ")"}
        "tan⁻¹": Operation.unaryOperation(atan, nil),        //{"tan⁻¹(" + $0 + ")"}
        "ln": Operation.unaryOperation(log, nil),            //{"ln(" + $0 + ")"}
        "x⁻¹": Operation.unaryOperation({1 / $0}, {"(" + $0 + ")⁻¹"}),
        "x²": Operation.unaryOperation({$0 * $0}, {"(" + $0 + ")²"}),
        "×": Operation.binaryOperation({ $0 * $1 }, nil),    //{$0 + "×" + $1}
        "÷": Operation.binaryOperation({ $0 / $1 }, nil),    //{$0 + "÷" + $1}
        "+": Operation.binaryOperation({ $0 + $1 }, nil),    //{$0 + "+" + $1}
        "-": Operation.binaryOperation({ $0 - $1 }, nil),    //{$0 + "−" + $1}
        "xʸ": Operation.binaryOperation(pow, {$0 + " ^ " + $1}),
        "=": Operation.equals
    ]
    
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .unaryOperation(let function, var descriptionFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    if descriptionFunction == nil {
                        descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                    descriptionAccumulator = descriptionFunction!(descriptionAccumulator!)
                }
            case .binaryOperation(let function, var descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    if descriptionFunction == nil {
                        descriptionFunction = {$0 + " " + symbol + " " + $1}
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: descriptionAccumulator!)
                    accumulator = nil
                    descriptionAccumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            
            descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        if let value = accumulator {
            descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""   //String(describing: NSNumber(value: value))
        }
    }
    mutating func clear () {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptionAccumulator = " "
        
    }
}
