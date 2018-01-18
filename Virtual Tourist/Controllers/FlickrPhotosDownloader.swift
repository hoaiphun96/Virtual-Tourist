//
//  FlickrPhotosDownloader.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/28/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import Foundation
import CoreData

public class FlickrPhotosDownloader  {
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    var pin : Pin?
    
    // MARK: Make Network Request
    
    public func getImageFromFlickr(pageNumber: Int, completionHandlerForGetImage: @escaping (_ foundImage: Bool,_ errorString: String?) -> Void) {
        // [creating the url and request]...
        let methodParameters = [
            Constants.FlickrParameterKeys.Lat: pin!.coordinate.latitude,
            Constants.FlickrParameterKeys.Long: pin!.coordinate.longitude,
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.page: "\(String(describing: pageNumber))",
            Constants.FlickrParameterKeys.perpage: Constants.FlickrParameterValues.perpage
            ] as [String : Any]
        
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // create network request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            guard error == nil else {
                print(error!)
                completionHandlerForGetImage(false, "URL at time of error: \(url)")
                return
            }
            
            // there was data returned
            if let data = data {
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    //TO DO: SHOW ALERT
                    completionHandlerForGetImage(false, "Could not parse the data as JSON: '\(data)'")
                    return
                }
                if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let pages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int {
                    
                    guard let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                        completionHandlerForGetImage(false, "No image")
                        return
                    }
                    // add photos to photos
                    // CASE CURRENTPAGE = NUMPAGES, DISABLE NEW COLLECTION
                    if let p = self.pin, let context = self.fetchedResultsController?.managedObjectContext {
                        // Delete old photos in collection view
                        for photo in (self.pin?.photos)! {
                            context.delete(photo as! NSManagedObject)
                        }
                        try! context.save()
                        guard pageNumber <= pages else {
                            completionHandlerForGetImage(false, "Out of bound")
                            return
                        }
                        //save new photos downloaded to CoreData
                        for photo in photoArray {
                            let photoURL = photo[Constants.FlickrResponseKeys.MediumURL] as! String
                            //add Photo to Core Data
                            let photo = Photo(url: photoURL, context: context)
                            photo.pin = p
                        }
                        completionHandlerForGetImage(true, nil)
        
                    }
                    
                }
            }
        }
        
        // start the task!
        task.resume()
        
    }
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
}
