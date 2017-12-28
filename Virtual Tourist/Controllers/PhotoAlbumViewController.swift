//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/26/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UICollectionViewController {

    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocationCoordinate2D!
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        configureMapView()
        configureToolBar(photoSelected: false)
        configureCollectionView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //change toolbar to Remove selected items
        configureToolBar(photoSelected: true)
        //delete items from model and fetched again
    }
    
    @IBAction func toolBarButtonClicked(_ sender: Any) {
        if toolBarButton.title == "New Collection" {
            //fetch new collection
        }
        else {
            //Delete photo
        }
    }
    func configureMapView() {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
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

    

}
