//
//  SetGame.swift
//  SetGame
//
//  Created by Pablo Leite on 07/07/2018.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import Foundation

protocol SetGameDelegate: AnyObject {
  func gameDidChange()
}

class SetGame {
    private let maxSelectedCards = 3
    private let setFoundPoints = 3
    private let setFailurePoints = -5
    private let maxVisibleCards: Int

    private var deck = Deck()
    private(set) var visibleCards = [Card]()
    private(set) var selectedCards = [Card]()
    private(set) var score = 0

    weak var delegate: SetGameDelegate?

    var isCardDeckEmpty: Bool {
        return deck.cards.isEmpty
    }

    init(maxVisibleCards: Int) {
        self.maxVisibleCards = maxVisibleCards
    }

    func initGame(drawing initialCardsCount: Int = 0) {
        deck = Deck()
        visibleCards.removeAll()
        selectedCards.removeAll()
        score = 0
        draw(numOfCards: initialCardsCount)

        delegate?.gameDidChange()
    }

    func draw(numOfCards: Int = 3) {
        guard visibleCards.count + numOfCards <= maxVisibleCards else {
            print("draw: Cannot draw more cards!")
            return
        }
        for _ in 0..<numOfCards {
            visibleCards.append(deck.cards.removeFirst())
        }

        delegate?.gameDidChange()
    }

    func chooseCard(_ card: Card) {
        let isCardSelected = selectedCards.contains(card)
        if !isCardSelected && selectedCards.count == maxSelectedCards {
            selectedCards.removeAll()
        }

        if !isCardSelected {
            selectedCards.append(card)
        } else if let selectedCardIndex = selectedCards.index(of: card) {
            selectedCards.remove(at: selectedCardIndex)
        }

        if (selectedCards.count == 3) {
            verifySet()
        }

        delegate?.gameDidChange()
    }

    func chooseCard(at cardIndex: Int) {
        let card = visibleCards[cardIndex]
        chooseCard(card)
    }

    func shuffleVisibleCards() {
        visibleCards.shuffle()
        delegate?.gameDidChange()
    }

    private func verifySet() {
        guard selectedCards.count == 3 else {
            return
        }

        let card1 = selectedCards[0]
        let card2 = selectedCards[1]
        let card3 = selectedCards[2]

        let isColorOk = (card1.color == card2.color && card2.color == card3.color) ||
                        (card1.color != card2.color && card2.color != card3.color)

        let isShapeOk = (card1.shape == card2.shape && card2.shape == card3.shape) ||
                        (card1.shape != card2.shape && card2.shape != card3.shape)

        let isCountOk = (card1.shapeCount == card2.shapeCount && card2.shapeCount == card3.shapeCount) ||
                        (card1.shapeCount != card2.shapeCount && card2.shapeCount != card3.shapeCount)

        let isShadingOk = (card1.shading == card2.shading && card2.shading == card3.shading) ||
                          (card1.shading != card2.shading && card2.shading != card3.shading)

        let isSet = isColorOk && isShapeOk && isCountOk && isShadingOk

        if isSet {
            for card in selectedCards {
                if let cardIndex = visibleCards.index(of: card) {
                    visibleCards.remove(at: cardIndex)
                    if !deck.cards.isEmpty {
                        visibleCards.insert(deck.cards.removeFirst(), at: cardIndex)
                    }
                } else {
                    print("UhOh! verifySet: Cannot replace set cards because card:\(card) is missing from visibleCards")
                }
            }
            selectedCards.removeAll()
        }
        updateScore(foundSet: isSet)
    }

    private func updateScore(foundSet: Bool) {
        score += foundSet ? setFoundPoints : setFailurePoints
    }


}
