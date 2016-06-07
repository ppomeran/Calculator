//
//  CalculatorBrain.swift
//  Calculator4
//
//  Created by Piret Pomerants on 06/06/16.
//  Copyright © 2016 Piret Pomerants. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, precedence: Int, (Double, Double) -> Double)
        case Constant(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                case .Constant(let constant, _):
                    return constant
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
// Dictionary syntax similar to Array. Key: Value
    private var knownOps = [String: Op]()
    
// Dictionary syntax as well:
// var knownOps = Dictionary<String, Op>()
    
    var text: String {
        return self.description
    }
    
    var description: String {
        get {
            var returnDesc = ""
            var returnOps = opStack
            repeat {
                let (additionalDesc, additionalOps) = describe(returnOps)
                if returnDesc.isEmpty {
                    returnDesc = additionalDesc
                } else {
                    returnDesc = additionalDesc+", "+returnDesc
                }
                returnOps = additionalOps
            } while !returnOps.isEmpty
            return returnDesc
        }
    }
    
// Initializer in CalculatorBrain
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", precedence: 150, *))
        learnOp(Op.BinaryOperation("÷", precedence: 150, { $1 / $0 }))
        learnOp(Op.BinaryOperation("+", precedence: 140, +))
        learnOp(Op.BinaryOperation("−", precedence: 140, { $1 - $0 }))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("±", {-$0}))
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func describe(ops: [Op], currentOpPrecedence: Int = 0) -> (description: String, remainder: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op  {
            case .Operand:
                return (op.description, remainingOps)
            case .UnaryOperation:
                let (operandDesc, remainingOps) = describe(remainingOps)
                return (op.description+"("+operandDesc+")", remainingOps)
            case .BinaryOperation(_, let precedence, _):
                let (operandDesc1, remainingOps1) = describe(remainingOps, currentOpPrecedence: precedence)
                let (operandDesc2, remainingOps2) = describe(remainingOps1, currentOpPrecedence: precedence)
                if precedence < currentOpPrecedence {
                    return ("("+operandDesc2+op.description+operandDesc1+")", remainingOps2)
                } else {
                    return (operandDesc2+op.description+operandDesc1, remainingOps2)
                }
            case .Constant:
                return (op.description, remainingOps)
            }
        }
        return ("?", ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let value):
                return (value, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
// Adding different operands to stack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
// Adding different operations to stack
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOpStack() {
        opStack.removeAll()
    }
    
}
