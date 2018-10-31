//
//  ViewController.swift
//  Project3
//
//  Created by Paul Hudson on 02/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var textFieldTip: UILabel!
    @IBOutlet var nextButton: UIButton!

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [textField]
    }

    var focusGuide: UIFocusGuide!

    override func viewDidLoad() {
        super.viewDidLoad()

        restoresFocusAfterTransition = false

        focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)

        focusGuide.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        focusGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        focusGuide.heightAnchor.constraint(equalToConstant: 1).isActive = true
        focusGuide.preferredFocusEnvironments = [nextButton]
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

        if context.nextFocusedView == textField {
            focusGuide.preferredFocusEnvironments = [nextButton]
        } else if context.nextFocusedView == nextButton {
            focusGuide.preferredFocusEnvironments = [textField]
        }

        if context.nextFocusedView == textField {
            coordinator.addCoordinatedAnimations({
                self.textFieldTip.alpha = 1
            })
        } else if context.previouslyFocusedView == textField {
            coordinator.addCoordinatedAnimations({
                self.textFieldTip.alpha = 0
            })
        }

        if let focusedView = UIScreen.main.focusedView {
            print(focusedView)
        }
    }

    @IBAction func showAlert(_ sender: Any) {
        let ac = UIAlertController(title: "Hello", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
}
