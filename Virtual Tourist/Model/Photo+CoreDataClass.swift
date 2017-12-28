//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/27/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//
//
import UIKit
import Foundation
import CoreData

public class Photo: NSManagedObject {
    convenience init(url: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.url = url
            let realURL = URL(string: url)
            
            let data = try! Data(contentsOf: realURL!)
            self.image = data as NSData
            
        }
        else {
            fatalError("Unable to find Entity name")
        }
    }
}


