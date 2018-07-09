//
//  Int+Random.swift
//  Concentration
//
//  Created by Pablo Leite on 01/07/2018.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import Foundation

extension Int {
    static func random(_ upperBound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperBound)))
    }
}
