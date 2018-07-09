//
//  Deck.swift
//  SetGame
//
//  Created by Pablo Leite on 07/07/2018.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import Foundation

struct Deck {
    var cards = [Card]()
    
    init() {
        var sequentialCards = [Card]()
        for shape in Card.Shape.all {
            for shapeCount in Card.ShapeCount.all {
                for color in Card.Color.all {
                    for shading in Card.Shading.all {
                        sequentialCards.append(Card(shape: shape, shapeCount: shapeCount, color: color, shading: shading))
                    }
                }
            }
        }
        
        cards = sequentialCards.shuffled()
    }

}
