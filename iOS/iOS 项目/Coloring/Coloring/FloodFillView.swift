//
//  FloodFillView.swift
//  Demo
//
//  Created by iaknus on 21/1/8.
//  Copyright © 2021年 IAKNUS. All rights reserved.
//

import UIKit

class FloodFillView: UIView, FloodFillDelegate {
    
    // MARK: - Square
    
    enum Flag: Int {
        case none = 0
        case mark = 1
        case block = 2
        case filled = 3
    }
    
    class Square {
        static var side: Double = 4
        static var padding: Double = 1
        
        var flag: Flag = .none
        var rect: CGRect
        var name: String
        
        private(set) var x: Int, y: Int
        
        init(point: Point) {
            (x, y) = point
            name = "x:\(x),y:\(y)"
            let row = Square.padding + Double(x) * (Square.side + Square.padding)
            let col = Square.padding + Double(y) * (Square.side + Square.padding)
            rect = CGRect(x: row, y: col, width: Square.side, height: Square.side)
        }
    }
    
    let floodFill = FloodFill()
    
    var squares: Dictionary<String, Square> = [:]
    
    convenience init(grid: Int) {
        self.init()
        
        floodFill.w = grid
        floodFill.h = grid
        floodFill.delegate = self
        
        for x in 0 ..< grid {
            for y in 0 ..< grid {
                let square = Square(point: (x, y))
                squares[square.name] = square
            }
        }
        
        addShape(center: (32, 32), radius: 28, startAngle: 0, endAngle: 360)
        addShape(center: (20, 26), radius: 6, startAngle: 0, endAngle: 360)
        addShape(center: (44, 26), radius: 6, startAngle: 0, endAngle: 360)
        addShape(center: (32, 30), radius: 20, startAngle: 30, endAngle: 150)
        
        let length = Double(grid) * Square.side + Double(grid + 1) * Square.padding
        bounds = CGRect(x: 0, y: 0, width: length, height: length)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    func addShape(center: Point, radius: Double, startAngle:Int, endAngle:Int) {
        for i in startAngle ..< endAngle {
            let angle = Double(i) * Double.pi / 180.0
            let x = Int(Double(center.x) + round(radius * cos(angle)))
            let y = Int(Double(center.y) + round(radius * sin(angle)))
            squares["x:\(x),y:\(y)"]?.flag = .block
        }
    }
        
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context:CGContext? = UIGraphicsGetCurrentContext()
        context?.setAllowsAntialiasing(true) // 抗锯齿设置
        context?.setFillColor(UIColor.red.cgColor)
        
        for square in squares.values {
            if square.flag == .filled {
                context?.setFillColor(UIColor.green.cgColor)
            } else if square.flag == .block {
                context?.setFillColor(UIColor.black.cgColor)
            } else if square.flag == .mark {
                context?.setFillColor(UIColor.red.cgColor)
            } else {
                context?.setFillColor(UIColor.white.cgColor)
            }
            context?.fill(square.rect)
        }
    }
    
    // 点击事件
    @objc func tap(_ sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.ended) {
            let point: CGPoint = sender.location(in: self)
            for square in squares.values where square.rect.contains(point) {
                DispatchQueue(label: "com.minyea.queue").async {
                    self.floodFill.floodFillScanline(x: square.x, y: square.y)
                }
                break
            }
        }
    }
    
    func reset() {
        for square in squares.values {
            square.flag = .none
        }
        
        onMain {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - FloodFillDelegate
    
    func canFloodFilling(x: Int, y: Int) -> Bool {
        if let square = squares["x:\(x),y:\(y)"] {
            return square.flag == .none || square.flag == .mark
        }
        return false
    }
    
    func floodFillingScan(x: Int, y: Int) {
        squares["x:\(x),y:\(y)"]?.flag = .mark
        
        onMain {
            self.setNeedsDisplay()
        }
        
        if !Thread.isMainThread {
            Thread.sleep(forTimeInterval: 0.01)
        }
    }
    
    func floodFilledAt(x: Int, y: Int) {
        squares["x:\(x),y:\(y)"]?.flag = .filled
        
        onMain {
            self.setNeedsDisplay()
        }
        
        if !Thread.isMainThread {
            Thread.sleep(forTimeInterval: 0.01)
        }
    }
    
}
