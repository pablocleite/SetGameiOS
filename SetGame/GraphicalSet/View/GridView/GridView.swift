//
//  GridView.swift
//  SetGame
//
//  Created by Pablo Cobucci Leite on 23/08/18.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import UIKit

class GridView: UIView {

  private let viewSpacing: CGFloat = 3

  private var grid = Grid(layout: .aspectRatio(2/3));

  override func didAddSubview(_ subview: UIView) {
    grid.cellCount += 1
  }

  override func willRemoveSubview(_ subview: UIView) {
    grid.cellCount -= 1
  }

  override func layoutSubviews() {
    grid.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

    for subviewIndex in subviews.indices {
      if let subViewFrame = grid[subviewIndex] {
        subviews[subviewIndex].frame = subViewFrame.insetBy(dx: viewSpacing, dy: viewSpacing)
      } else {
        print("UhOh! A subview frame has not been found in the grid!")
      }
    }
  }

}
