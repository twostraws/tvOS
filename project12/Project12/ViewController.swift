//
//  ViewController.swift
//  Project12
//
//  Created by Paul Hudson on 10directory/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var imageSelection: UISegmentedControl!

    var resourceRequest: NSBundleResourceRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard

        let defaultSettings: [String: Any] = ["favoriteNumber": 556, "safeWord": "Klaatu barada nikto"]
        defaults.register(defaults: defaultSettings)

        defaults.set(556, forKey: "favoriteNumber")
        defaults.set("Klaatu barada nikto", forKey: "safeWord")
        defaults.set(["Sophie", "Charlotte", "Paul"], forKey: "names")

        print(defaults.integer(forKey: "favoriteNumber"))
        print(defaults.string(forKey: "safeWord") ?? "We're all doomed!")

        if let array = defaults.array(forKey: "names") as? [String] {
            print(array)
        }

        

        let store = NSUbiquitousKeyValueStore.default
        print(store.string(forKey: "Greeting") ?? "Na-Nu Na-Nu")
        store.set("Bah-weep-graaaaagnah wheep nini bong", forKey: "Greeting")
        store.synchronize()
    }

    @IBAction func selectionChanged(_ sender: Any) {
        let requestedImage = "image\(imageSelection.selectedSegmentIndex + 1)"

        fetch(tags: [requestedImage]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let imagePath = self.resourceRequest?.bundle.url(forResource: requestedImage, withExtension: "jpg") {
                    if let imageData = UIImage(contentsOfFile: imagePath.path) {
                        self.imageView.image = imageData
                    }
                }
            }
        }
    }

    @IBAction func markComplete(_ sender: Any) {
        resourceRequest?.endAccessingResources()
    }

    func fetch(tags: Set<String>, completion: @escaping (Error?) -> Void) {
        resourceRequest?.progress.cancel()

        resourceRequest = NSBundleResourceRequest(tags: tags)
        resourceRequest?.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent

        resourceRequest?.progress.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: .new, context: nil)

        resourceRequest?.beginAccessingResources { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object as? Progress else { return }

        DispatchQueue.main.async {
            self.progressView.progress = Float(object.fractionCompleted)
        }
    }
}

