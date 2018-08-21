//
//  SetCardView.swift
//  SetGame
//
//  Created by Pablo Cobucci Leite on 21/08/18.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {

  //MARK: - IBInspectables
  @IBInspectable var ibShape: Int {
    set(newValue) {
      shape = Shape(rawValue: newValue) ?? shape
    }
    get {
      return shape.rawValue
    }
  }

  @IBInspectable var ibCount: Int {
    set(newValue) {
      shapeCount = ShapeCount(rawValue: newValue) ?? shapeCount
    }
    get {
      return shapeCount.rawValue
    }
  }

  @IBInspectable var ibColor: Int {
    set(newValue) {
      color = Color(rawValue: newValue) ?? color
    }
    get {
      return color.rawValue
    }
  }

  @IBInspectable var ibShading: Int {
    set(newValue) {
      shading = Shading(rawValue: newValue) ?? shading
    }
    get {
      return shading.rawValue
    }
  }


  //MARK: - Properties
  private var shape: Shape = .oval
  private var shapeCount: ShapeCount = .two
  private var color: Color = .red
  private var shading: Shading = .solid

  override func draw(_ rect: CGRect) {
    drawBorder()

    switch shape {
    case .oval:
      drawOvalShape()
    case .diamond:
      drawDiamondShape()
    case .squiggle:
      drawSquiggleShape()
    }
  }

  private func drawBorder() {
    let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
    roundedRect.addClip() //Will enforce clipping outside this rounded rect.
    UIColor.white.setFill()
    roundedRect.fill()
  }

  private func drawOvalShape() {
    switch shapeCount {
    case .one:
      drawSingleOvalShape(bounds: centerShapeBounds)
    case .two:
      let topShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: -shapeSize.height))
      drawSingleOvalShape(bounds: topShapeBounds)
      let bottomShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: shapeSize.height))
      drawSingleOvalShape(bounds: bottomShapeBounds)
    case .three:
      let topShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: -(shapeSize.height + shapeSize.height*0.5)))
      drawSingleOvalShape(bounds: topShapeBounds)

      drawSingleOvalShape(bounds: centerShapeBounds)

      let bottomShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: shapeSize.height + shapeSize.height*0.5))
      drawSingleOvalShape(bounds: bottomShapeBounds)
    }
  }

  private func drawSingleOvalShape(bounds: CGRect) {
    let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: shapeSize.height * 0.5)
    color.uiColor.setFill()
    roundedRect.fill()
  }

  private func drawDiamondShape() {

  }

  private func drawSquiggleShape() {

  }

}

extension SetCardView {

  private var cornerRadius: CGFloat {
    return bounds.size.height * 0.08
  }

  private var shapeWidthRatio: CGFloat {
    return 0.8
  }

  private var shapeWidthHeightRatio: CGFloat {
    return 1/3
  }

  private var shapeWidth: CGFloat {
    return bounds.size.width * shapeWidthRatio
  }

  private var shapeSize: CGSize {
    return CGSize(width: shapeWidth, height: shapeWidth * shapeWidthHeightRatio)
  }

  private var centerShapeBounds: CGRect {
    let origin = CGPoint(x: bounds.midX - shapeSize.width / 2, y: bounds.midY - shapeSize.height / 2)
    return CGRect(origin: origin, size: shapeSize)
  }

  enum Shape: Int {
    case oval
    case squiggle
    case diamond
  }

  enum ShapeCount: Int {
    case one = 1
    case two
    case three
  }

  enum Color: Int {
    case red
    case purple
    case green

    var uiColor: UIColor {
      switch self {
        case .red:
          return .red
        case .purple:
          return .purple
        case .green:
          return .green
      }
    }

  }

  enum Shading: Int {
    case solid
    case stripped
    case outlined
  }

}
