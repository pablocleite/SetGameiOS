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

            cardGridView.delegate = self
        }
    }
    @IBOutlet weak var scoreLabel: UILabel!

    //MARK: - Constants
    private static let maxVisibleCards = 81
    private static let initialCardsDrawn = 12
    private static let numberOfCardsToDraw = 3
    private static let minShuffleRotationAngle = CGFloat.degToRad(45)

    //MARK: - Porperties
    private lazy var game: SetGame = {
        var game = SetGame(maxVisibleCards: GraphicalSetViewController.maxVisibleCards)
        game.delegate = self
        return game
    }()

    private lazy var cardViewsDict = [Card:SetCardView]()
    private weak var drawCardsTimer: Timer?
    private var isDrawingInitialCards = false

    override func viewDidLoad() {
        initGame()
    }

    @IBAction func didTouchResetButton(_ sender: UIButton) {
        initGame()
    }

    //MARK: - Private methods
    private func initGame() {
        game.initGame(drawing: 0)

        cardGridView.elementCount = GraphicalSetViewController.initialCardsDrawn
        isDrawingInitialCards = true
        drawCardsTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true, block: { [weak self] (timer) in
            self?.game.draw(numOfCards: 1)
            if self?.game.visibleCards.count == GraphicalSetViewController.initialCardsDrawn {
                self?.isDrawingInitialCards = false
                timer.invalidate()
            }
        })
    }

    private func updateViewFromModel() {

        let cardsToRemove = cardViewsDict.keys.filter( { !game.visibleCards.contains($0) } )
        let cardsToAdd = game.visibleCards.filter( { !cardViewsDict.keys.contains($0) } )

        if !isDrawingInitialCards {
            cardGridView.elementCount -= cardsToRemove.count
            cardGridView.elementCount += cardsToAdd.count
        }

        cardsToRemove.forEach({ (card) in
            cardViewsDict[card]?.removeFromSuperview()
            cardViewsDict.removeValue(forKey: card)
        })

        cardsToAdd.forEach { (card) in
            let cardViewModel = CardViewModel(from: card)
            let cardView = SetCardView(frame: deckCardView.frame)
            cardView.isFaceUp = false
            cardView.shape = cardViewModel.shape
            cardView.shapeCount = cardViewModel.shapeCount
            cardView.color = cardViewModel.color
            cardView.shading = cardViewModel.shading
            cardView.isSelected = game.selectedCards.contains(card)
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchCardView(_:))))
            cardViewsDict[card] = cardView
            cardGridView.addSubview(cardView)
        }

        let currentSelectedCards = cardViewsDict.values.filter({ $0.isSelected })
        currentSelectedCards.forEach({ $0.isSelected = false })

        game.selectedCards.forEach { (card) in
            cardViewsDict[card]?.isSelected = true
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

extension GraphicalSetViewController: GridViewDelegate {
    func didFinishViewTransitionAnimation(view: UIView) {
        if let cardView = view as? SetCardView {
            if !cardView.isFaceUp {
                UIView.transition(with: cardView,
                                  duration: 0.2,
                                  options: [.transitionFlipFromLeft],
                                  animations: { cardView.isFaceUp = true })
            }
        }
    }
}

extension GraphicalSetViewController: SetGameDelegate {
    func gameDidChange() {
        updateViewFromModel()
    }
}
