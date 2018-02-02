//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Nick on 1/29/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    private var cache: (accumulator: Double?, descriptionAccumulator: String?)
    
    //    private var accumulator: Double?
    //    private var descriptionAccumulator: String?
    
    var description: String? {
        get {
            if pendingBinaryOperation == nil {
                return cache.descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, cache.descriptionAccumulator ?? "")
            }
        }
    }
    
    var result: Double? {
        get {
            return cache.accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.notANumberSymbol = "Error"
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter
    } ()
    
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
                cache = (function(), descriptionValue)
                
            case .constant(let value):
                cache = (value, symbol)
                //                cache.accumulator = value
                //                cache.descriptionAccumulator = symbol
                
            case .unaryOperation(let function, var descriptionFunction):
                if cache.accumulator != nil {
                    cache.accumulator = function(cache.accumulator!)
                    if descriptionFunction == nil {
                        descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                    cache.descriptionAccumulator = descriptionFunction!(cache.descriptionAccumulator!)
                }
            case .binaryOperation(let function, var descriptionFunction):
                performPendingBinaryOperation()
                if cache.accumulator != nil {
                    if descriptionFunction == nil {
                        descriptionFunction = {$0 + " " + symbol + " " + $1}
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: cache.accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: cache.descriptionAccumulator!)
                    cache = (nil, nil)
                    // cache.accumulator = nil
                    // cache.descriptionAccumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && cache.accumulator != nil {
            cache.accumulator = pendingBinaryOperation!.perform(with: cache.accumulator!)
            
            cache.descriptionAccumulator = pendingBinaryOperation!.performDescription(with: cache.descriptionAccumulator!)
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
        cache.accumulator = operand
        if let value = cache.accumulator {
            cache.descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
        }
    }
    mutating func clear () {
        cache = (nil, " ")
        //cache.accumulator = nil
        //cache.descriptionAccumulator = " "
        pendingBinaryOperation = nil
    }
}
