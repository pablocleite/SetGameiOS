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

    @IBOutlet weak var matchedDeckCardView: SetCardView!

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
    @IBOutlet weak var resetButton: UIButton!
    
    //MARK: - Constants
    private static let maxVisibleCards = 81
    private static let initialCardsDrawn = 12
    private static let numberOfCardsToDraw = 3
    private static let minShuffleRotationAngle = CGFloat.degToRad(45)
    private static let cardGridViewSpacing: CGFloat = 8
    private static let drawCardDuration: TimeInterval = 0.15

    //MARK: - Porperties
    private lazy var game: SetGame = {
        var game = SetGame(maxVisibleCards: GraphicalSetViewController.maxVisibleCards)
        game.delegate = self
        return game
    }()

    private lazy var cardViewsDict = [Card:SetCardView]()
    private weak var drawCardsTimer: Timer?
    private var isDrawingCards = false {
        didSet {
            deckCardView.isUserInteractionEnabled = !isDrawingCards
            resetButton.isEnabled = !isDrawingCards
        }
    }

    override func viewDidLoad() {
        initGame()
    }

    override func viewDidLayoutSubviews() {
        cardGridView.contentInsets = UIEdgeInsets(top: 0,
                                                  left: deckCardView.frame.width + GraphicalSetViewController.cardGridViewSpacing,
                                                  bottom: 0,
                                                  right: 0)
    }

    @IBAction func didTouchResetButton(_ sender: UIButton) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4,
                                                       delay: 0,
                                                       options: [.curveEaseOut],
                                                       animations: { [weak self] in
                                                        self?.cardViewsDict.values.forEach { (cardView) in
                                                            cardView.alpha = 0
                                                        }
        },
                                                       completion: { [weak self] (position) in
                                                        self?.cardViewsDict.values.forEach({ $0.removeFromSuperview() })
                                                        self?.cardViewsDict.removeAll()
                                                        self?.cardGridView.elementCount = 0
                                                        self?.deckCardView.isHidden = false
                                                        self?.matchedDeckCardView.isHidden = true
                                                        self?.initGame()
        })
    }

    //MARK: - Private methods
    private func initGame() {
        game.initGame()
        drawMoreCards(GraphicalSetViewController.initialCardsDrawn)
    }

    private func updateViewFromModel() {
        let cardsToRemove = cardViewsDict.keys.filter( { !game.visibleCards.contains($0) } )
        let cardsToAdd = game.visibleCards.filter( { !cardViewsDict.keys.contains($0) } )

        if !isDrawingCards {
            cardGridView.elementCount -= cardsToRemove.count
            cardGridView.elementCount += cardsToAdd.count
        }

        cardsToRemove.forEach({ (card) in
            removeCard(card)
        })

        cardsToAdd.forEach { (card) in
            let initialFrame = CGRect(x: deckCardView.frame.minX,
                                      y: deckCardView.frame.minY,
                                      width: deckCardView.frame.width,
                                      height: deckCardView.frame.height)

            let cardView = createCardView(with: card, withFrame: initialFrame)
            cardViewsDict[card] = cardView
            cardGridView.addSubview(cardView, isManaged: true)
        }

        let currentSelectedCards = cardViewsDict.values.filter({ $0.isSelected })
        currentSelectedCards.forEach({ $0.isSelected = false })

        game.selectedCards.forEach { (card) in
            cardViewsDict[card]?.isSelected = true
        }

        deckCardView.isHidden = game.isCardDeckEmpty
        scoreLabel.text = "Score\n\(game.score)"
    }

    private func createCardView(with card: Card, withFrame frame: CGRect) -> SetCardView {
        let cardViewModel = CardViewModel(from: card)
        let cardView = SetCardView(frame: frame)
        cardView.isFaceUp = false
        cardView.shape = cardViewModel.shape
        cardView.shapeCount = cardViewModel.shapeCount
        cardView.color = cardViewModel.color
        cardView.shading = cardViewModel.shading
        cardView.isSelected = game.selectedCards.contains(card)
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchCardView(_:))))
        return cardView
    }

    private func removeCard(_ card: Card, animated: Bool = true) {
        if let cardView = cardViewsDict[card] {
            cardGridView.stopManagingSubview(cardView)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                           delay: 0,
                                                           options: [.curveEaseInOut],
                                                           animations: { [unowned self] in
                                                            cardView.frame = self.matchedDeckCardView.frame
                }, completion: { [unowned self] (position) in
                    self.matchedDeckCardView.isHidden = true
                    cardView.flipCard() { [weak self] in
                        self?.matchedDeckCardView.isHidden = false
                        self?.cardViewsDict.removeValue(forKey: card)
                        $0.removeFromSuperview()
                    }
            })
        }
    }

    private func drawMoreCards(_ cardsToDraw: Int = GraphicalSetViewController.numberOfCardsToDraw) {
        cardGridView.elementCount += cardsToDraw
        isDrawingCards = true
        drawCardsTimer = Timer.scheduledTimer(withTimeInterval: GraphicalSetViewController.drawCardDuration,
                                              repeats: true,
                                              block: { [weak self] (timer) in
                                                self?.game.draw(numOfCards: 1)
                                                if self?.game.visibleCards.count == self?.cardGridView.elementCount {
                                                    self?.isDrawingCards = false
                                                    timer.invalidate()
                                                }
        })
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
            if let touchedCardView = gestureRecognizer.view {
                let cardViewPair = cardViewsDict.filter { (_, cardView) -> Bool in
                    return cardView == touchedCardView
                }.first
                if let card = cardViewPair?.key {
                    game.chooseCard(card)
                }
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
                cardView.flipCard()
            }
        }
    }
}

extension GraphicalSetViewController: SetGameDelegate {
    func gameDidChange() {
        updateViewFromModel()
    }
}

extension SetCardView {
    private static let flipCardAnimationDuration: TimeInterval = 0.2
    func flipCard(animated: Bool = true, completion: ((SetCardView) -> Void)? = nil) {
        UIView.transition(with: self,
                          duration: SetCardView.flipCardAnimationDuration,
                          options: [.transitionFlipFromLeft],
                          animations: { [unowned self] in self.isFaceUp = !self.isFaceUp },
                          completion: { (didFinish) in completion?(self) })
    }
}
