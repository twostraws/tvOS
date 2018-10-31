//
//  ServiceProvider.swift
//  TopShelf
//
//  Created by Paul Hudson on 09/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }

    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .inset
    }

    var topShelfItems: [TVContentItem] {
        // Create an array of TVContentItems.
        var items = [TVContentItem]()

        for i in 1 ... 3 {
            let id = UUID().uuidString
            let identifier = TVContentIdentifier(identifier: id, container: nil)
            let item = TVContentItem(contentIdentifier: identifier)
            
            item.setImageURL(Bundle.main.url(forResource: String(i), withExtension: "jpg"), forTraits: .userInterfaceStyleLight)
            item.setImageURL(Bundle.main.url(forResource: String(i), withExtension: "jpg"), forTraits: .userInterfaceStyleDark)
            item.displayURL = URL(string: "project9://display/\(id)")
            item.playURL = URL(string: "project9://play/\(id)")
            items.append(item)
        }

        return items
    }
}

