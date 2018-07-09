//
//  ViewController.swift
//  SetGame
//
//  Created by Pablo Leite on 07/07/2018.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var drawCardsButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet var cardButtons: [UIButton]! {
        didSet {
            cardButtons.forEach { $0.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) }
        }
    }
    
    private lazy var game = SetGame(maxVisibleCards: cardButtons.count)
    
    private let shapeCharacter: [Card.Shape : String] = [
        .shape1 : "▲",
        .shape2 : "■",
        .shape3 : "●"
    ]
    
    private let colorMap: [Card.Color : UIColor] = [
        .color1 : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1),
        .color2 : #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1),
        .color3 : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    ]
    
    private let shadingAlphaColorMap: [Card.Shading : CGFloat] = [
        .outlined : 1.0,
        .solid : 1.0,
        .stripped : 0.15
    ]
    
    private let shadingStrokeWidthrMap: [Card.Shading : Int] = [
        .outlined : 5,
        .solid : -1,
        .stripped : -1
    ]
    
    
    
    override func viewDidLoad() {
        game.initGame()
        updateViewFromModel()
    }
    
    func updateViewFromModel() {
        var visibleCardIterator = game.visibleCards.makeIterator();
        for cardButton in cardButtons {
            if let visibleCard = visibleCardIterator.next() {
                cardButton.isHidden = false
                
                let shape = shapeCharacter[visibleCard.shape]!
                var cardFace = ""
                for _ in 0..<visibleCard.shapeCount.rawValue {
                    cardFace.append("\(shape)\n")
                }
                cardFace.removeLast()
                
                let cardAttributes: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.strokeWidth : shadingStrokeWidthrMap[visibleCard.shading]!,
                    NSAttributedStringKey.foregroundColor : colorMap[visibleCard.color]!.withAlphaComponent(shadingAlphaColorMap[visibleCard.shading]!),
                    NSAttributedStringKey.strokeColor : colorMap[visibleCard.color]!
                ]
                
                let attributedCardFace = NSAttributedString(string: cardFace, attributes: cardAttributes)
                cardButton.setAttributedTitle(attributedCardFace, for: .normal)
                
                cardButton.layer.borderWidth =  game.selectedCards.contains(visibleCard) ? 4.0 : 0.0
            } else {
                cardButton.isHidden = true
            }
        }
        
        drawCardsButton.isEnabled = !game.isCardDeckEmpty
        scoreLabel.text = "Score: \(game.score)"
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        guard let visibleCardIndex = cardButtons.index(of: sender) else {
            print("UhOh! TouchCard, sender button not found on cardButtons!")
            return
        }
        game.chooseCard(at: visibleCardIndex)
        updateViewFromModel()
    }
    
    @IBAction func touchDealThreeCards(_ sender: UIButton) {
        game.draw()
        updateViewFromModel()
    }
    
    @IBAction func touchReset(_ sender: UIButton) {
        game.initGame()
        updateViewFromModel()
    }
    
}

