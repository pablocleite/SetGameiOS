//
//  CGFloat+Rads.swift
//  SetGame
//
//  Created by Pablo Cobucci Leite on 24/08/18.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import CoreGraphics

extension CGFloat {
  static func degToRad(_ degrees: CGFloat) -> CGFloat {
    return degrees * .pi / 180
  }
}
