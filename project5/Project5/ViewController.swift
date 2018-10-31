//
//  ViewController.swift
//  Project5
//
//  Created by Paul Hudson on 04/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var language: UISegmentedControl!
    @IBOutlet var words: UISegmentedControl!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? GameViewController else { return }
        vc.targetLanguage = language.titleForSegment(at: language.selectedSegmentIndex)!.lowercased()
        vc.wordType = words.titleForSegment(at: words.selectedSegmentIndex)!.lowercased()
    }
}

