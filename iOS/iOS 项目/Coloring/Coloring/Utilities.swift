//
//  Utilities.swift
//  Coloring
//
//  Created by iaknus on 2021/1/11.
//  Copyright © 2021 IAKNUS. All rights reserved.
//

import UIKit

public func onMain(_ closure: @escaping () -> ()) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}
