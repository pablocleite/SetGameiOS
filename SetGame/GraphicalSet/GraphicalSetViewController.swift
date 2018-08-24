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

  @IBOutlet weak var cardGridView: GridView! {
    didSet {
      let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeOnCardGridView(_:)))
      swipeGestureRecognizer.direction = .down
      cardGridView.addGestureRecognizer(swipeGestureRecognizer)

      let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotateOnCardGridView(_:)))
      cardGridView.addGestureRecognizer(rotationGestureRecognizer)
    }
  }
  @IBOutlet weak var scoreLabel: UILabel!

  //MARK: - Constants
  private static let maxVisibleCards = 81
  private static let initialCardsDrawn = 0
  private static let numberOfCardsToDraw = 3
  private static let minShuffleRotationAngle = CGFloat.degToRad(45)

  //MARK: - Porperties
  private lazy var game: SetGame = {
    var game = SetGame(maxVisibleCards: GraphicalSetViewController.maxVisibleCards)
    game.delegate = self
    return game
  }()

  override func viewDidLoad() {
    initGame()
  }

  @IBAction func didTouchResetButton(_ sender: UIButton) {
    initGame()
  }

  //MARK: - Private methods
  private func initGame() {
    game.initGame(drawing: GraphicalSetViewController.initialCardsDrawn)
  }

  private func updateViewFromModel() {
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

  private func drawMoreCards() {
    game.draw(numOfCards: GraphicalSetViewController.numberOfCardsToDraw)
  }

  //MARK: - GestureRecognizer selectors
  @objc func didTouchDeckCardView(_ gestureRecognizer: UITapGestureRecognizer) {
    switch gestureRecognizer.state {
    case .ended:
      drawMoreCards()
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
      }
    default:
      break
    }
  }

  @objc func didSwipeOnCardGridView(_ gestureRecognizer: UISwipeGestureRecognizer) {
    drawMoreCards()
  }

  @objc func didRotateOnCardGridView(_ gestureRecognizer: UIRotationGestureRecognizer) {
    switch gestureRecognizer.state {
    case .ended:
      let rotationAbs = fabs(gestureRecognizer.rotation)
      if rotationAbs >= GraphicalSetViewController.minShuffleRotationAngle {
        game.shuffleVisibleCards()
      }
    default:
      break
      }
  }
}

extension GraphicalSetViewController: SetGameDelegate {
  func gameDidChange() {
    updateViewFromModel()
  }
}
