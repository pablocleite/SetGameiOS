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

  @IBInspectable var stripeSpacing: CGFloat = 4.0 {
    didSet {
      guard stripeSpacing > 1 else {
        stripeSpacing = oldValue
        return
      }
      setNeedsDisplay()
    }
  }

  @IBInspectable var shapeStrokeWidth: CGFloat = 2.0 {
    didSet {
      guard shapeStrokeWidth > 0 else {
        shapeStrokeWidth = oldValue
        return
      }
      setNeedsDisplay()
    }
  }

  @IBInspectable var isFaceUp: Bool = false {
    didSet {
      setNeedsDisplay()
    }
  }


  //MARK: - Properties
  private var shape: Shape = .oval
  private var shapeCount: ShapeCount = .two
  private var color: Color = .red
  private var shading: Shading = .solid

  override func draw(_ rect: CGRect) {
    drawCard()
    if (isFaceUp) {
      drawShapes()
    } else {
      drawBackOfCard()
    }
  }

  private func drawCard() {
    let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height * cardCornerRadiusRatio)
    roundedRect.addClip() //Will enforce clipping outside this rounded rect.
    UIColor.white.setFill()
    roundedRect.fill()
  }

  private func drawBackOfCard() {
    let backOfCardBounds: CGRect = bounds.insetBy(dx: bounds.width * 0.05, dy: bounds.width * 0.05)
    let roundedRect = UIBezierPath(roundedRect: backOfCardBounds, cornerRadius: backOfCardBounds.height * cardCornerRadiusRatio)
    roundedRect.addClip() //Will enforce clipping outside this rounded rect.
    UIColor.orange.setFill()
    roundedRect.fill()
  }

  private func drawShapes() {
    switch shapeCount {
    case .one:
      drawSingleShape(bounds: centerShapeBounds)
    case .two:
      let topShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: -shapeSize.height))
      drawSingleShape(bounds: topShapeBounds)
      let bottomShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: shapeSize.height))
      drawSingleShape(bounds: bottomShapeBounds)
    case .three:
      let topShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: -(shapeSize.height + shapeSize.height*0.5)))
      drawSingleShape(bounds: topShapeBounds)

      drawSingleShape(bounds: centerShapeBounds)

      let bottomShapeBounds = centerShapeBounds.applying(CGAffineTransform(translationX: 0, y: shapeSize.height + shapeSize.height*0.5))
      drawSingleShape(bounds: bottomShapeBounds)
    }
  }

  private func drawShading(on shape: UIBezierPath, withinBounds bounds: CGRect) {
    guard let cgContext = UIGraphicsGetCurrentContext() else {
      print("Current CGContext is nil, cannot draw shading.")
      return
    }

    cgContext.saveGState()
    switch shading {
    case .solid:
      color.uiColor.setFill()
      shape.fill()
    case .outlined:
      color.uiColor.setStroke()
      shape.stroke()
    case .stripped:
      shape.addClip() //The main shape must be the clipping path, so stripes can be safelly drawn within bounds.
      color.uiColor.setStroke()
      shape.stroke()

      for y in stride(from: bounds.origin.y, to: bounds.origin.y + bounds.size.height, by: stripeSpacing) {
        let line = UIBezierPath()
        line.move(to: CGPoint(x: bounds.origin.x, y: y))
        line.addLine(to: CGPoint(x: bounds.origin.x + bounds.size.width, y: y))
        line.stroke()
      }
    }

    cgContext.restoreGState()
  }

  private func drawSingleShape(bounds: CGRect) {
    switch shape {
    case .oval:
      drawSingleOvalShape(bounds: bounds)
    case .diamond:
      drawSingleDiamondShape(bounds: bounds)
    case .squiggle:
      drawSingleSquiggleShape(bounds: bounds)
    }
  }

  private func drawSingleOvalShape(bounds: CGRect) {
    let shape = UIBezierPath(roundedRect: bounds, cornerRadius: shapeSize.height * 0.5)
    shape.lineWidth = shapeStrokeWidth
    drawShading(on: shape, withinBounds: bounds)
  }

  private func drawSingleDiamondShape(bounds: CGRect) {
    let shape = UIBezierPath()
    shape.lineWidth = shapeStrokeWidth
    shape.move(to: CGPoint(x: bounds.origin.x, y: bounds.midY))
    shape.addLine(to: CGPoint(x: bounds.midX, y: bounds.origin.y))
    shape.addLine(to: CGPoint(x: bounds.origin.x + bounds.size.width, y: bounds.midY))
    shape.addLine(to: CGPoint(x: bounds.midX, y: bounds.origin.y + bounds.size.height))
    shape.close()

    drawShading(on: shape, withinBounds: bounds)
  }

  private func drawSingleSquiggleShape(bounds: CGRect) {
    let shape = UIBezierPath()
    shape.lineWidth = shapeStrokeWidth
    shape.move(to: CGPoint(x: bounds.origin.x + bounds.size.width * 0.05, y: bounds.origin.y + bounds.size.height * 0.65))

    shape.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width * 0.80, y: bounds.origin.y + bounds.size.height * 0.35),
                   controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width * 0.10, y: bounds.origin.y - bounds.size.height * 0.55),
                   controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width * 0.65, y: bounds.origin.y + bounds.size.height * 1.25))

    shape.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width * 0.90, y: bounds.origin.y + bounds.size.height * 0.65),
                   controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width * 0.9, y: bounds.origin.y + bounds.size.height * 0.15),
                   controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width * 0.90, y: bounds.origin.y + bounds.size.height * 0.55))

    shape.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width * 0.20, y: bounds.origin.y + bounds.size.height * 0.55),
                   controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width * 0.95, y: bounds.origin.y + bounds.size.height * 1.35),
                   controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width * 0.40, y: bounds.origin.y + bounds.size.height * 0.45))

    shape.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width * 0.05, y: bounds.origin.y + bounds.size.height * 0.65),
                   controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width * 0.10, y: bounds.origin.y + bounds.size.height * 0.70),
                   controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width * 0.08, y: bounds.origin.y + bounds.size.height * 0.7))


    drawShading(on: shape, withinBounds: bounds)
  }

}

extension SetCardView {

  private var cardCornerRadiusRatio: CGFloat {
    return 0.08
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
