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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocationCoordinate2D!
    @IBOutlet weak var collectionView: UICollectionView!
    var blockOperations = [BlockOperation]()
    var currentPage: Int!
    var selectedPhotos = Set<Photo>()
    let noImageLabel = UILabel()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView?.reloadData()
        }
    }
    
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // CHECK IF PHOTOS IN USERDEFAULT
        configureMapView()
        configureToolBar(photoSelected: false)
        configureCollectionView()
        guard UserDefaults.standard.bool(forKey: "\(pin.objectID)") else {
            // if never been loaded, set current page to 1, load new set of photos
            currentPage = 1
            loadPhotos(currentPage)
            return
        }
        //else, use the persisted data and update the current page of this pin
        currentPage = UserDefaults.standard.integer(forKey: "Page \(pin.objectID)")
        print("number of blur view photos", self.selectedPhotos.count)
    }
    
    func loadPhotos(_ atPage: Int) {
        let loadPhoto = FlickrPhotosDownloader()
        loadPhoto.pin = pin
        loadPhoto.fetchedResultsController = fetchedResultsController
        loadPhoto.getImageFromFlickr(pageNumber: atPage) { (foundImage, errorString) in
            UserDefaults.standard.set(true, forKey: "\(self.pin.objectID)")
            //If don't find any photo, display "No image found"
            //if no image is found at all, then display "no image found",
            guard foundImage else {
                self.displayLabel()
                return
            }
            //else
            UserDefaults.standard.set(self.currentPage, forKey: "Page \(self.pin.objectID)")
            UserDefaults.standard.synchronize()
        }
        do {
            try fetchedResultsController?.managedObjectContext.save()
        } catch {
            print(error)
        }

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
    
    func deletePhotos() {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        fr.includesPropertyValues = false
        if let result = try? fetchedResultsController?.managedObjectContext.fetch(fr) {
            for object in result! {
                fetchedResultsController?.managedObjectContext.delete(object as! Photo)
            }
        }
        try! fetchedResultsController?.managedObjectContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //change toolbar to Remove selected items
        configureToolBar(photoSelected: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! photoViewCell
        let photo = fetchedResultsController!.object(at: indexPath) as! Photo
        if selectedPhotos.contains(photo) {
            selectedPhotos.remove(photo)
            cell.removeBlurView()
        } else {
            selectedPhotos.insert(photo)
            cell.addBlurView()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController!.object(at: indexPath) as! Photo
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! photoViewCell
        
        // Configure the cell
        cell.imageView.image = UIImage(data: photo.image! as Data)
        cell.removeBlurView()
        return cell
    }
    
    
    @IBAction func toolBarButtonClicked(_ sender: Any) {
        if toolBarButton.title == "New Collection" {
            currentPage = currentPage + 1
            print("toolbar clicked",currentPage)
            deletePhotos()
            selectedPhotos.removeAll()
            loadPhotos(currentPage)
            print(selectedPhotos.count)
            
        }
        else {
            //Delete photo
            for photo in selectedPhotos {
                fetchedResultsController?.managedObjectContext.delete(photo)
            }
            configureToolBar(photoSelected: false)
            try! fetchedResultsController?.managedObjectContext.save()
        }
        
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
    
    
}
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView?.insertItems(at: [newIndexPath!])
                    }
                })
            )
            
        case .delete:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView?.deleteItems(at: [indexPath!])
                    }
                })
            )
            
        case .update:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView?.reloadItems(at: [indexPath!])
                    }
                })
            )
        case .move:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView?.moveItem(at: indexPath!, to: newIndexPath!)
                        
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
}
