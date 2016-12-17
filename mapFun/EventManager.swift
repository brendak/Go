//
//  AppDelegate.swift
//  Go!
//
//  Created by Brenda Kaing on 12/9/16.
//  Copyright © 2016 Brenda Kaing. All rights reserved.
//

import Foundation
import MapKit

class Entry: NSObject, MKAnnotation {
    var title: String?
    let detail: String
    let date: Date
    let coordinate: CLLocationCoordinate2D
    let address: String
    
    init(title: String, detail: String, date: Date, coordinate: CLLocationCoordinate2D, address: String) {
        self.title = title
        self.detail = detail
        self.date = date
        self.coordinate = coordinate
        self.address = address

        super.init()
    }
    
    var subtitle: String? {
        return self.detail + "\n" + dateFormat(date: self.date) + "\n" + self.address
    }
}

func dateFormat (date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let dateFromString = dateFormatter.string(from: date)
    return dateFromString
}

