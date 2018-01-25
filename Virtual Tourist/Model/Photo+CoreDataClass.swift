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
        } else {
            fatalError("Unable to find Entity name")
        }
    }
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            if data == nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                completionHandler(data, nil)
            }
        }
        
        task.resume()
        return task
    }
}

