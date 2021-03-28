//
//  ColorPaintView.swift
//  Minesweeper
//
//  Created by iaknus on 2021/1/11.
//  Copyright © 2021 IAKNUS. All rights reserved.
//

import UIKit

class ColorPaintView: UIView, FloodFillDelegate {
    
    let floodFill = FloodFill()
    
    var strokePath: UIBezierPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        floodFill.w = Int(frame.width)
        floodFill.h = Int(frame.height)
        floodFill.delegate = self
        
        let path = UIBezierPath()
        path.append(arcPath(x: 0, y: 0, radius: 140, fromAngle: 0, toAngle: 360))
        path.append(arcPath(x: -60, y: -30, radius: 30, fromAngle: 0, toAngle: 360))
        path.append(arcPath(x: 60, y: -30, radius: 30, fromAngle: 0, toAngle: 360))
        path.append(arcPath(x: 0, y: -10, radius: 100, fromAngle: 30, toAngle: 150))
        
        let templateLayer = CAShapeLayer()
        templateLayer.path = path.cgPath
        templateLayer.zPosition = 10
        templateLayer.lineWidth = 3.0
        templateLayer.strokeColor = UIColor.black.cgColor
        templateLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(templateLayer)

        strokePath = UIBezierPath(cgPath: path.cgPath.copy(strokingWithWidth: 1.0, lineCap: path.lineCapStyle, lineJoin: path.lineJoinStyle, miterLimit: path.miterLimit))

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    func arcPath(x: CGFloat, y:CGFloat, radius: CGFloat, fromAngle:Double, toAngle:Double) -> UIBezierPath {
        let center = CGPoint(x: self.center.x + x, y: self.center.y + y)
        let startAngle = CGFloat(fromAngle * Double.pi / 180.0)
        let endAngle = CGFloat(toAngle * Double.pi / 180.0)
        
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    // 点击事件
    @objc func tap(_ sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.ended) {
            let point: CGPoint = sender.location(in: self)
            let (x, y) = (Int(point.x), Int(point.y))
            
            if canFloodFilling(x: x, y: y) {
                DispatchQueue(label: "com.minyea.queue").async {
                    var rects: [CGRect] = []
                    for (x, y) in self.floodFill.floodFillScanline(x: x, y: y) {
                        rects.append(CGRect(x: x, y: y, width: 1, height: 1))
                    }

                    onMain {
                        let colorPaintLayer = ColorPaintLayer()
                        colorPaintLayer.frame = self.layer.bounds
                        colorPaintLayer.rects = rects
                        self.layer.addSublayer(colorPaintLayer)
                    }
                }
            }
        }
    }
    
    var squares: Dictionary<String, (Int, Int)> = [:]
        
    // MARK: - FloodFillDelegate
    
    func canFloodFilling(x: Int, y: Int) -> Bool {
        if let _ = squares["x:\(x),y:\(y)"] {
            return false
        }
        if let strokePath = strokePath, strokePath.contains(CGPoint(x: x, y: y)) {
            return false
        }
        return true
    }
    
    func floodFilledAt(x: Int, y: Int) {
        squares["x:\(x),y:\(y)"] = (x, y)
    }
}
