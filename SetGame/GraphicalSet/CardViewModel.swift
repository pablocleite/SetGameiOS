//
//  CardViewModel.swift
//  SetGame
//
//  Created by Pablo Cobucci Leite on 23/08/18.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import Foundation

struct CardViewModel {

  var shape: SetCardView.Shape
  var shapeCount: SetCardView.ShapeCount
  var color: SetCardView.Color
  var shading: SetCardView.Shading


  init(from card: Card) {
    switch card.shape {
    case .shape1:
      shape = .diamond
    case .shape2:
      shape = .oval
    case .shape3:
      shape = .squiggle
    }

    switch card.shapeCount {
    case .one:
      shapeCount = .one
    case .two:
      shapeCount = .two
    case .three:
      shapeCount = .three
    }

    switch card.color {
    case .color1:
      color = .red
    case .color2:
      color = .green
    case .color3:
      color = .purple
    }

    switch card.shading {
    case .solid:
      shading = .solid
    case .outlined:
      shading = .outlined
    case .stripped:
      shading = .stripped
    }
  }
}
