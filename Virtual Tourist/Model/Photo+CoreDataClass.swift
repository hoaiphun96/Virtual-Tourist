//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/28/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

public class Photo: NSManagedObject {
    convenience init(url: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.url = url
            let realURL = URL(string: url)
            if let data = try? Data(contentsOf: realURL!) {
                self.image = data as NSData
            }
        }
        else {
            fatalError("Unable to find Entity name")
        }
    }
}

