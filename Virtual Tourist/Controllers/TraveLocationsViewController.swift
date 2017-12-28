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

class TraveLocationsViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "lon", ascending: true)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
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
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            // add pin to core data
            let pin = Pin(lat: annotation.coordinate.latitude, lon: annotation.coordinate.longitude, context: fetchedResultsController!.managedObjectContext)
            print("just created a new Pin \(pin)")
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer.view == mapView)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        controller.location = view.annotation?.coordinate
        navigationController?.pushViewController(controller, animated: true)
       
        //self.performSegue(withIdentifier: "presentPhotos", sender: fetchedResultsController!.)
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
                
                /*
                
                // Create FetchedResultsController
                let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                
                // Inject it into the notesVC
                photosVC.fetchedResultsController = fc
                
                // Inject the notebook too!
                photosVC.pin = notebook */
            }
        }
    }

}
