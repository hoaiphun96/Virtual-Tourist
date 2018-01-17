//
//  configurePhotoAlbumView.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/28/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import Foundation
import MapKit

extension PhotoAlbumViewController {
    
    func configureMapView() {
        
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            DispatchQueue.main.async {
                self.mapView.setRegion(region, animated: true)
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.location
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
        }
    }
    
    func configureToolBar(photoSelected: Bool) {
        toolBarButton.title = photoSelected ? "Remove Selected Pictures" : "New Collection"
    }
    
    func configureCollectionView() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func displayLabel() {
        DispatchQueue.main.async {
            self.toolBarButton.isEnabled = false
            self.noImageLabel.frame = self.collectionView.bounds
            self.noImageLabel.text = "This pin has no images"
            self.noImageLabel.textAlignment = NSTextAlignment.center
            self.collectionView.addSubview(self.noImageLabel)
        }
    }
}
