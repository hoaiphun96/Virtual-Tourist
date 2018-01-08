//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/26/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

// MARK: - Constants

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Lat = "lat"
        static let Long = "lon"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let page = "page"
        static let perpage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let APIKey = "d354e8818404746239d656e6a9b014e1"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let SearchPhotosMethod = "flickr.photos.search"
        static let MediumURL = "url_m"
        static let perpage = "21"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Page = "page"
        static let Pages = "pages"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}

