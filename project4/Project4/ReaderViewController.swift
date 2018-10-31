//
//  ReaderViewController.swift
//  Project4
//
//  Created by Paul Hudson on 03/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ReaderViewController: UIViewController {
    var article: JSON?

    @IBOutlet var headline: UILabel!
    @IBOutlet var imageView: RemoteImageView!
    @IBOutlet var body: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let article = article else { return }

        body.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.indirect.rawValue] as [NSNumber]
        body.isSelectable = true

        if let url = article["fields"]["thumbnail"].url {
            imageView.load(url)
            imageView.layer.borderColor = UIColor.darkGray.cgColor
            imageView.layer.borderWidth = 2
            imageView.layer.cornerRadius = 20
        }

        headline.text = article["fields"]["headline"].stringValue
        body.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let articleBody = article["fields"]["body"].stringValue
        let formattedArticleBody = formatHTML(articleBody)

        if let articleBodyData = formattedArticleBody.data(using: .utf8) {
            if let bodyText = try? NSAttributedString(data: articleBodyData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                body.attributedText = bodyText
            }
        }
    }

    func formatHTML(_ html: String) -> String {
        guard let wrapperURL = Bundle.main.url(forResource: "wrapper", withExtension: "html") else { return html }
        guard let wrapper = try? String(contentsOf: wrapperURL) else { return html }
        return wrapper.replacingOccurrences(of: "%@", with: html)
    }
}
