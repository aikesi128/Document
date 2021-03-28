//
//  ColorPaintLayer.swift
//  Coloring
//
//  Created by iaknus on 2021/1/12.
//  Copyright © 2021 IAKNUS. All rights reserved.
//

import UIKit

class ColorPaintLayer: CAShapeLayer {
    
    var rects: [CGRect] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
        
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        ctx.setFillColor(UIColor.red.cgColor)
        ctx.fill(rects)
    }
        
} 
