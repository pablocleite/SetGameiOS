//
//  GraphicalSetViewController.swift
//  SetGame
//
//  Created by Pablo Cobucci Leite on 23/08/18.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import UIKit

class GraphicalSetViewController: UIViewController {


  //MARK: - IBOutlets
  @IBOutlet weak var deckCardView: SetCardView! {
    didSet {
      deckCardView.isUserInteractionEnabled = true
      deckCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchDeckCardView(_:))))
    }
  }

  @IBOutlet weak var cardGridView: GridView!
  @IBOutlet weak var scoreLabel: UILabel!

  //MARK: - Constants
  private static let maxVisibleCards = 81
  private static let initialCardsDrawn = 0

  //MARK: - Porperties
  private var game = SetGame(maxVisibleCards: GraphicalSetViewController.maxVisibleCards)

  override func viewDidLoad() {
    initGame()
  }


  func updateViewFromModel() {
    //TODO: Improve this, let's make it work for now, but attempt to not do this every time.
    cardGridView.subviews.forEach( { $0.removeFromSuperview() })

    for visibleCard in game.visibleCards {
      let cardViewModel = CardViewModel(from: visibleCard)
      let cardView = SetCardView(frame: .zero)
      cardView.isFaceUp = true
      cardView.shape = cardViewModel.shape
      cardView.shapeCount = cardViewModel.shapeCount
      cardView.color = cardViewModel.color
      cardView.shading = cardViewModel.shading
      cardView.isSelected = game.selectedCards.contains(visibleCard)
      cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchCardView(_:))))
      cardGridView.addSubview(cardView)
    }

    deckCardView.isHidden = game.isCardDeckEmpty
    scoreLabel.text = "Score\n\(game.score)"
    
  }

  private func initGame() {
    game.initGame(drawing: GraphicalSetViewController.initialCardsDrawn)
    updateViewFromModel()
  }

  @IBAction func didTouchResetButton(_ sender: UIButton) {
    initGame()
  }

  @objc func didTouchDeckCardView(_ gestureRecognizer: UITapGestureRecognizer) {
    switch gestureRecognizer.state {
    case .ended:
      game.draw(numOfCards: 3)
      //TODO: Implement a delegation for the game!
      updateViewFromModel()
    default:
      break
    }
  }

  @objc func didTouchCardView(_ gestureRecognizer: UITapGestureRecognizer) {
    switch gestureRecognizer.state {
    case .ended:
      if let touchedCardView = gestureRecognizer.view,
        let touchedCardIndex = cardGridView.subviews.index(of: touchedCardView) {
        game.chooseCard(at: touchedCardIndex)
        updateViewFromModel()
      }
    default:
      break
    }
  }

}
