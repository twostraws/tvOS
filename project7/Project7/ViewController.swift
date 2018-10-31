//
//  ViewController.swift
//  Project7
//
//  Created by Paul Hudson on 05/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!

    var pages = [String: JSON]()
    var firstRun = true

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 51.38, longitude: -2.36)
        updateMap()
    }

    func focus(on city: City) {
        mapView.centerCoordinate = city.coordinates
    }

    func updateMap() {
        guard let url = URL(string: "https://en.wikipedia.org/w/api.php?ggscoord=\(self.mapView.centerCoordinate.latitude)%7C\(self.mapView.centerCoordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json") else { return }

        DispatchQueue.global(qos: .userInteractive).async {
            if let data = try? Data(contentsOf: url) {
                let json = JSON(data)
                self.pages = json["query"]["pages"].dictionaryValue
                DispatchQueue.main.async {
                    self.reloadAnnotations()
                }
            }
        }
    }

    func reloadAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        var visibleMap = MKMapRect.null

        for page in pages.values {
            let point = MKPointAnnotation()
            point.title = page["title"].stringValue
            point.coordinate = CLLocationCoordinate2D(latitude: page["coordinates"][0]["lat"].doubleValue, longitude: page["coordinates"][0]["lon"].doubleValue)
            mapView.addAnnotation(point)

            let mapPoint = MKMapPoint(point.coordinate)
            let pointRect = MKMapRect(x: mapPoint.x, y: mapPoint.y, width: 0.1, height: 0.1)
            visibleMap = visibleMap.union(pointRect)
        }

        if firstRun {
            mapView.setVisibleMapRect(visibleMap, edgePadding: UIEdgeInsets(top: 60, left: 60, bottom: 90, right: 90), animated: true)
            firstRun = false
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMap()
    }
}

