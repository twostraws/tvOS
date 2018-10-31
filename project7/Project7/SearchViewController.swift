//
//  SearchViewController.swift
//  Project7
//
//  Created by Paul Hudson on 05/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import CoreLocation
import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    @IBOutlet var tableView: UITableView!
    weak var mainTabBarController: UITabBarController!    

    var allCities = [City]()
    var matchingCities = [City]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let capitalsURL = Bundle.main.url(forResource: "capitals", withExtension: "json") else { return }
        guard let contents = try? Data(contentsOf: capitalsURL) else { return }

        let cities = JSON(contents).arrayValue

        for city in cities {
            let coords = CLLocationCoordinate2D(latitude: city["lat"].doubleValue, longitude: city["lon"].doubleValue)
            let newCity = City(name: city["name"].stringValue, country: city["country"].stringValue, coordinates: coords)
            allCities.append(newCity)
        }

        allCities.sort()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingCities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let city = matchingCities[indexPath.row]
        cell.textLabel?.text = city.formattedName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let map = mainTabBarController.viewControllers?.first as? ViewController else { return }

        let city = matchingCities[indexPath.row]
        map.focus(on: city)

        mainTabBarController.selectedViewController = map
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchController.searchBar.text else { return }

        if search.isEmpty {
            matchingCities = allCities
        } else {
            matchingCities = allCities.filter {
                $0.matches(search)
            }
        }

        tableView.reloadData()
    }
}
