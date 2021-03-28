//
//  FloodFill.swift
//  Demo
//
//  Created by iaknus on 21/1/8.
//  Copyright © 2021年 IAKNUS. All rights reserved.
//

import Foundation

typealias Point = (x: Int, y: Int)

protocol FloodFillDelegate {
    func canFloodFilling(x: Int, y: Int) -> Bool
    
    func floodFillingScan(x: Int, y: Int)
    func floodFilledAt(x: Int, y: Int)
}

extension FloodFillDelegate {
    func floodFillingScan(x: Int, y: Int) {}
    func floodFilledAt(x: Int, y: Int) {}
}

class FloodFill {
    
    struct Stack<Point> {
        private var items = [Point]()
        
        mutating func push(_ item: Point) {
            items.append(item)
        }
        mutating func pop() -> Point? {
            if !items.isEmpty {
                return items.removeLast()
            }
            return nil
        }
    }
    
    var delegate: FloodFillDelegate?
    
    var w: Int = 0, h: Int = 0
    var executing: Bool = false
    
    @discardableResult
    func floodFillScanline(x: Int, y: Int) -> [Point] {
        var fillingPoints: Array<Point> = []
        
        if executing || !canFilled(point: (x, y)) {
            return fillingPoints
        }
        
        executing = true
        
        var x1: Int
        var spanAbove: Bool, spanBelow: Bool
        
        var stack = Stack<Point>()
        stack.push((x, y))
                
        while let (x, y) = stack.pop() {
            x1 = x
            while x1 >= 0 && canFilled(point: (x1, y)) {
                x1 -= 1
            }
            x1 += 1
            
            spanAbove = false
            spanBelow = false

            while x1 < w && canFilled(point: (x1, y)) {
                delegate?.floodFilledAt(x: x1, y: y)
                fillingPoints.append((x1, y))
                
                if !spanAbove && y > 0 && canFilled(point: (x1, y - 1)) {
                    stack.push((x1, y - 1))
                    spanAbove = true
                    delegate?.floodFillingScan(x: x1, y: y - 1)
                } else if spanAbove && y > 0 && !canFilled(point: (x1, y - 1)) {
                    spanAbove = false
                }
                
                if !spanBelow && y < h - 1 && canFilled(point: (x1, y + 1)) {
                    stack.push((x1, y + 1))
                    spanBelow = true
                    delegate?.floodFillingScan(x: x1, y: y + 1)
                } else if spanBelow && y < h - 1 && !canFilled(point: (x1, y + 1)) {
                    spanBelow = false
                }
                
                x1 += 1
            }
        }
        
        executing = false
        
        return fillingPoints
    }
    
    func canFilled(point: Point) -> Bool {
        if let delegate = delegate {
            return delegate.canFloodFilling(x: point.x, y: point.y)
        }
        return false
    }
}
