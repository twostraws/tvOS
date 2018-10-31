//
//  City.swift
//  Project7
//
//  Created by Paul Hudson on 05/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import CoreLocation
import Foundation

struct City: Comparable {
    var name: String
    var country: String
    var coordinates: CLLocationCoordinate2D

    var formattedName: String {
        return "\(name) (\(country))"
    }

    static func <(lhs: City, rhs: City) -> Bool {
        return lhs.name < rhs.name
    }

    static func ==(lhs: City, rhs: City) -> Bool {
        return lhs.name == rhs.name
    }

    func matches(_ text: String) -> Bool {
        return name.localizedCaseInsensitiveContains(text) || country.localizedCaseInsensitiveContains(text)
    }
}
