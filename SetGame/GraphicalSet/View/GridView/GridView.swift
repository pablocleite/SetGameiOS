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

    private var managedSubviews = [UIView]()

    var contentInsets = UIEdgeInsets.zero {
        didSet {
             setNeedsLayout()
        }
    }

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

    func addSubview(_ view: UIView, isManaged: Bool) {
        if isManaged {
            managedSubviews.append(view)
        }
        addSubview(view)
    }

    func stopManagingSubview(_ view: UIView) {
        managedSubviews = managedSubviews.filter({ $0 != view})
    }

    override func willRemoveSubview(_ subview: UIView) {
        if let index = managedSubviews.index(of: subview) {
            managedSubviews.remove(at: index)
        }
    }

    override func layoutSubviews() {
        grid.frame = CGRect(x: contentInsets.left,
                            y: contentInsets.top,
                            width: frame.width - contentInsets.left - contentInsets.right,
                            height: frame.height - contentInsets.top - contentInsets.bottom)

        for subviewIndex in managedSubviews.indices {
            if let subViewFrame = grid[subviewIndex] {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3,
                                                               delay: 0.0,
                                                               options: [.curveEaseInOut],
                                                               animations: {
                                                                [unowned self] in
                                                                self.managedSubviews[subviewIndex].frame = subViewFrame.insetBy(dx: self.viewSpacing, dy: self.viewSpacing)
                                                               },
                                                               completion: { [unowned self] (position) in
                                                                self.delegate?.didFinishViewTransitionAnimation(view: self.managedSubviews[subviewIndex])
                                                               })
            } else {
                print("UhOh! A subview frame has not been found in the grid!")
            }
        }
    }

}
