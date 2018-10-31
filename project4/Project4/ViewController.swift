//
//  ViewController.swift
//  Project4
//
//  Created by Paul Hudson on 03/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UISearchResultsUpdating {
    var apiKey = "94896a2e-33cd-497f-aaa3-3c6940c72639"
    var articles = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let title = title else { return }
        guard let url = URL(string: "https://content.guardianapis.com/\(title.lowercased())?api-key=\(apiKey)&show-fields=thumbnail,headline,standfirst,body") else { return }

        DispatchQueue.global(qos: .userInteractive).async {
            self.fetch(url)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let newsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? NewsCell else { fatalError("Couldn't dequeue a cell") }

        let newsItem = articles[indexPath.row]
        let title = newsItem["fields"]["headline"].stringValue
        let thumbnail = newsItem["fields"]["thumbnail"].stringValue

        newsCell.textLabel.text = title

        if let imageURL = URL(string: thumbnail) {
            newsCell.imageView.load(imageURL)
        }

        return newsCell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let reader = storyboard?.instantiateViewController(withIdentifier: "Reader") as? ReaderViewController else { return }
        reader.article = articles[indexPath.row]
        present(reader, animated: true)
    }

    func fetch(_ url: URL) {
        if let data = try? Data(contentsOf: url) {
            articles = JSON(data)["response"]["results"].arrayValue

            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        } else {
            // something went wrong
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }

        if text.isEmpty {
            articles = [JSON]()
            collectionView?.reloadData()
        } else {
            guard let url = URL(string: "https://content.guardianapis.com/search?api-key=\(apiKey)&q=\(text)&show-fields=thumbnail,headline,standfirst,body") else { return }

            DispatchQueue.global(qos: .userInteractive).async {
                self.fetch(url)
            }
        }
    }
}

