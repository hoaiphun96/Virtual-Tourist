//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/28/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//
//

import Foundation
import MapKit
import CoreData

public class Pin: NSManagedObject, MKAnnotation {
    convenience init(lat: Double, lon: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = lat
            self.lon = lon
        }
        else {
            fatalError("Unable to find Entity name")
        }
    }
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        set {
            self.lat = newValue.latitude
            self.lon = newValue.longitude
        }
    }
}
