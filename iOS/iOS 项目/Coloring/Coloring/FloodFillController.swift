//
//  ViewController.swift
//  Demo
//
//  Created by iaknus on 21/1/8.
//  Copyright © 2021年 IAKNUS. All rights reserved.
//

import UIKit

class FloodFillController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var algorithm: UIPickerView!
    
    let choices = [
        "4-Way Recursive Method",
        "4-Way Method With Stack",
        "8-Way Recursive Method",
        "8-Way Method With Stack",
        "Recursive Scanline Floodfill Algorithm",
        "Scanline Floodfill Algorithm With Stack"
    ]
    
    lazy var floodFillView: FloodFillView! = {
        let view = FloodFillView(grid: 64)
        view.backgroundColor = .gray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floodFillView.center = view.center
        view.insertSubview(floodFillView, at: 0)
        
        algorithm.selectRow(choices.count - 1, inComponent: 0, animated: false)
    }
    
    // MARK: - UIPickerViewDelegate & UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.red
        
        if row < choices.count {
            label.text = choices[row]
        }
        return label
    }
    
}

