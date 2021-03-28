//
//  ColorPaintController.swift
//  Minesweeper
//
//  Created by iaknus on 2021/1/11.
//  Copyright © 2021 IAKNUS. All rights reserved.
//

import UIKit

class ColorPaintController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorPaintView = ColorPaintView(frame: view.bounds)
        colorPaintView.center = view.center
        view.insertSubview(colorPaintView, at: 0)
    }

}
