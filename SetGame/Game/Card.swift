//
//  Card.swift
//  SetGame
//
//  Created by Pablo Leite on 07/07/2018.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import Foundation

struct Card: Hashable {
    let identifier: Int
    let shape: Shape
    let shapeCount: ShapeCount
    let color: Color
    let shading: Shading
    
    private static var identifierFactory = 0
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init(shape: Shape, shapeCount: ShapeCount, color: Color, shading: Shading) {
        identifier = Card.getUniqueIdentifier()
        self.shape = shape
        self.shapeCount = shapeCount
        self.color = color
        self.shading = shading
    }
    
    enum Shape {
        case shape1
        case shape2
        case shape3
        
        static var all = [Shape.shape1, .shape2, .shape3]
    }
    
    enum ShapeCount: Int {
        case one = 1
        case two
        case three
        
        static var all = [ShapeCount.one, .two, .three]
    }
    
    enum Color {
        case color1
        case color2
        case color3
        
        static var all = [Color.color1, .color2, .color3]
    }
    
    enum Shading {
        case solid
        case stripped
        case outlined
        
        static var all = [Shading.solid, .stripped, .outlined]
    }
    
}
