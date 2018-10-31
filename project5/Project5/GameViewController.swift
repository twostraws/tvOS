//
//  GameViewController.swift
//  Project5
//
//  Created by Paul Hudson on 04/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class GameViewController: UICollectionViewController {
    var targetLanguage = "english"
    var wordType = ""
    var words: [JSON]!

    var cells = [Int: CardCell]()
    var first: CardCell?
    var second: CardCell?

    var numCorrect = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let wordsPath = Bundle.main.url(forResource: wordType, withExtension: "json") else { return }
        guard let contents = try? Data(contentsOf: wordsPath) else { return }
        words = JSON(contents).arrayValue

        var cellNumbers = Array(0 ..< 18)
        cellNumbers.shuffle()

        for i in 0 ..< 9 {
            let pictureNumber = cellNumbers.removeLast()
            let wordNumber = cellNumbers.removeLast()

            let pictureIndexPath = IndexPath(item: pictureNumber, section: 0)
            let wordIndexPath = IndexPath(item: wordNumber, section: 0)

            guard let wordCell = collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: wordIndexPath) as? CardCell else { return }
            guard let pictureCell = collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: pictureIndexPath) as? CardCell else { return }

            wordCell.word = words[i]["english"].stringValue
            wordCell.textLabel.text = words[i][targetLanguage].stringValue

            pictureCell.word = wordCell.word
            pictureCell.contents.image = UIImage(named: pictureCell.word)

            cells[pictureNumber] = pictureCell
            cells[wordNumber] = wordCell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cells[indexPath.row]!
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return false }
        return !cell.word.isEmpty
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }

        if first == nil {
            first = cell
        } else if second == nil && cell != first {
            second = cell

            view.isUserInteractionEnabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.checkAnswer()
            }
        } else {
            return
        }

        cell.flip(to: "cardFrontNormal", hideContents: false)
    }

    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            if let previous = context.previouslyFocusedView {
                previous.transform = .identity
            }

            if let next = context.nextFocusedView {
                next.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        })
    }

    func checkAnswer() {
        guard let firstCard = first, let secondCard = second else { return }

        if firstCard.word == secondCard.word {
            firstCard.word = ""
            secondCard.word = ""

            firstCard.card.image = UIImage(named: "cardFrontHighlighted")
            secondCard.card.image = UIImage(named: "cardFrontHighlighted")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.transition(with: firstCard.card, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    firstCard.card.image = UIImage(named: "cardFrontCorrect")
                })

                UIView.transition(with: secondCard.card, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    secondCard.card.image = UIImage(named: "cardFrontCorrect")
                })

                self.numCorrect += 1

                if self.numCorrect == 9 {
                    self.gameOver()
                }
            }
        } else {
            firstCard.flip(to: "cardBack", hideContents: true)
            secondCard.flip(to: "cardBack", hideContents: true)
        }

        first = nil
        second = nil
        view.isUserInteractionEnabled = true
    }

    func gameOver() {
        let imageView = UIImageView(image: UIImage(named: "youWin"))
        imageView.center = view.center
        imageView.alpha = 0
        imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        view.addSubview(imageView)

        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            imageView.alpha = 1
            imageView.transform = .identity
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
        }
    }
}
