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
    var deletePinMode: Bool?
    let delegate = UIApplication.shared.delegate as! AppDelegate
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
        //let persistentContainer = delegate.persistentContainer
        let stack = delegate.stack
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "lon", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context , sectionNameKeyPath: nil, cacheName: nil)
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
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.pins)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureUI(withToolbar: false)
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(dropAPin(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        guard let result = try? fetchedResultsController?.managedObjectContext.fetch(fr) else {
            print("No pin found")
            return
        }
        pins = result as! [Pin]
        try! fetchedResultsController?.managedObjectContext.save()
        print(pins.count)
        reloadMap()
    }
    
    func configureUI(withToolbar: Bool) {
        if withToolbar {
            DispatchQueue.main.async {
                self.mapView.frame = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: self.mapView.frame.width, height: self.mapView.frame.height - 60)
            }
            rightButton.title = "Done"
        }
        else {
            DispatchQueue.main.async {
                self.mapView.frame = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: self.mapView.frame.width, height: self.mapView.frame.height + 60)
                
            }
            rightButton.title = "Edit"
        }
        deletePinMode = !withToolbar
        toolBar.isHidden = !withToolbar
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
            delegate.stack.save()
            mapView.addAnnotation(pin)
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer.view == mapView)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation as? Pin
        guard deletePinMode! else {
            //add selected pin to selectedPin array
            fetchedResultsController?.managedObjectContext.delete(selectedAnnotation!)
            mapView.removeAnnotation(selectedAnnotation!)
            try! fetchedResultsController?.managedObjectContext.save()
            return
        }
        mapView.deselectAnnotation(selectedAnnotation, animated: false)
        selectedAnnotation?.lat = (view.annotation?.coordinate.latitude)!
        selectedAnnotation?.lon = (view.annotation?.coordinate.longitude)!
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
                
                let pred = NSPredicate(format: "pin = %@", argumentArray: [selectedAnnotation!])
                fr.predicate = pred
                let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                
                // Inject it into the PhotoAlbumVC
                photosVC.fetchedResultsController = fc
                let coordinate = selectedAnnotation?.coordinate
                photosVC.location = coordinate
                // Inject the pin too!
                photosVC.pin = selectedAnnotation
            
            }
        }
    }
    
}
