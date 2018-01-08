//
//  TraveLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/26/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TraveLocationsViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    var selectedAnnotation: Pin?
    var pins = [Pin]()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            reloadMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        //let stack = delegate.stack
        let persistentContainer = delegate.persistentContainer
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "lon", ascending: true)]
        
        // Create the FetchedResultsController
        //fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
    func reloadMap() {
        var annotations = [MKAnnotation]()
        for p in pins {
            let lat = CLLocationDegrees(p.lat)
            let lon = CLLocationDegrees(p.lon)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
            DispatchQueue.main.async {
                self.mapView.addAnnotations(annotations)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureUI(withToolbar: false)
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(dropAPin(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func configureUI(withToolbar: Bool) {
        if withToolbar {
            DispatchQueue.main.async {
                self.mapView.frame = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: self.mapView.frame.width, height: self.mapView.frame.height - 60)
            }
            rightButton.title = "Done"
            toolBar.isHidden = false
        }
        else {
            DispatchQueue.main.async {
                self.mapView.frame = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: self.mapView.frame.width, height: self.mapView.frame.height + 60)
                
            }
            toolBar.isHidden = true
            rightButton.title = "Edit"
        }
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        if rightButton.title == "Edit" {
            configureUI(withToolbar: true)
        }
        else {
            configureUI(withToolbar: false)
        }
    }
    
    @objc func dropAPin(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        if (gestureReconizer.state == UIGestureRecognizerState.began) {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = self.mapView.convert(location, toCoordinateFrom: mapView)
            
            //add pin to core data and to mapView annotations
            let pin = Pin(lat: coordinate.latitude, lon: coordinate.longitude, context: fetchedResultsController!.managedObjectContext)
            print("just created a new Pin \(pin)")
            pin.coordinate = coordinate
            mapView.addAnnotation(pin)
            
            
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer.view == mapView)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation as? Pin
        
        performSegue(withIdentifier: "presentPhotos", sender: self)
    }
  
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "presentPhotos" {
            
            if let photosVC = segue.destination as? PhotoAlbumViewController {
                
                // Create Fetch Request
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                fr.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
                
                //fetchedResultsController?.
                
                let selectedPin = fetchedResultsController?.managedObjectContext.object(with: (selectedAnnotation?.objectID)!) as! Pin
                // Create FetchedResultsController
                let pred = NSPredicate(format: "pin = %@", argumentArray: [selectedPin])
                fr.predicate = pred
                
                let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                
                // Inject it into the notesVC
                photosVC.fetchedResultsController = fc
                photosVC.location = selectedPin.coordinate
                // Inject the notebook too!
                photosVC.pin = selectedPin
              
            }
        }
    }
    
}
