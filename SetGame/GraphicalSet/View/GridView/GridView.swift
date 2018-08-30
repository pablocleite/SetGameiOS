//
//  GridView.swift
//  SetGame
//
//  Created by Pablo Cobucci Leite on 23/08/18.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import UIKit

protocol GridViewDelegate: AnyObject {
    func didFinishViewTransitionAnimation(view: UIView)
}

class GridView: UIView {

    weak var delegate: GridViewDelegate?

    private let viewSpacing: CGFloat = 3
    private var grid = Grid(layout: .aspectRatio(2/3));

    var elementCount: Int {
        set(newValue) {
            grid.cellCount = newValue
        }
        get {
            return grid.cellCount
        }
    }

    override func layoutSubviews() {
        grid.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

        for subviewIndex in subviews.indices {
            if let subViewFrame = grid[subviewIndex] {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3,
                                                               delay: 0.0,
                                                               options: [.curveEaseInOut],
                                                               animations: { [unowned self] in
                                                                self.subviews[subviewIndex].frame = subViewFrame.insetBy(dx: self.viewSpacing, dy: self.viewSpacing)
                    },
                                                               completion: { [unowned self] (position) in
                                                                self.delegate?.didFinishViewTransitionAnimation(view: self.subviews[subviewIndex])
                })
            } else {
                print("UhOh! A subview frame has not been found in the grid!")
            }
        }
    }

}
