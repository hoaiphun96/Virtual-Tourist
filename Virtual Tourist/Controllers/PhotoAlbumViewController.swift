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
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
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
        //Configure UI
        configureMapView()
        configureToolBar(photoSelected: false)
        configureCollectionView()
        //Check if this pin has any photo
        if pin.photos?.count == 0 {
            loadPhotos()
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
    
    //MARK: HELPER METHODS TO LOAD and DELETE PHOTOS
    func loadPhotos() {
        let loadPhoto = FlickrPhotosDownloader()
        loadPhoto.pin = pin
        loadPhoto.fetchedResultsController = fetchedResultsController
 
        let pages = UserDefaults.standard.integer(forKey: "Number of pages for \(String(describing: self.pin?.objectID))")
        let perpage = Int(Constants.FlickrParameterValues.perpage)
        let randomInt = arc4random_uniform(UInt32(min(pages,Int(400/perpage!))))
        
        loadPhoto.getImageFromFlickr(pageNumber: Int(randomInt) + 1) { (foundImage, errorString) in
    
            //If don't find any photo, display "No image found"
            //if no image is found at all, then display "no image found",
            guard foundImage else {
                self.displayLabel()
                return
            }
        }
        self.delegate.stack.save()
        
        
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
        delegate.stack.save()
    }
    
    //MARK: TOOLBAR CLICKED METHOD TO LOAD NEW COLLECTION OR DELETE PHOTOS FROM COLLECTION
    @IBAction func toolBarButtonClicked(_ sender: Any) {
        if toolBarButton.title == "New Collection" {
            //next page = randome within the range of number of pages at that location
            deletePhotos()
            selectedPhotos.removeAll()
            loadPhotos()
        }
        else {
            //Delete photo
            for photo in selectedPhotos {
                fetchedResultsController?.managedObjectContext.delete(photo)
            }
            configureToolBar(photoSelected: false)
            delegate.stack.save()
        }
    }
    
    //MARK: COLLECTION VIEW DELEGATE METHODS
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //change toolbar to Remove selected items
        configureToolBar(photoSelected: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoViewCell
        //Pull image from database if it's loaded before

        if photo.image != nil  {
            let p = UIImage(data: photo.image! as Data)
            cell.imageView.image = p
        } else { //else download new image
            let ai = ActivityIndicator()
            cell.imageView.image = nil
            ai.showLoader(cell.imageView)
            let _ = photo.downloadImage(imagePath: photo.url!, completionHandler: { (data, errorString) in
                if errorString == nil {
                    photo.image = data! as NSData
                    self.delegate.stack.save()
                    DispatchQueue.main.async {
                        ai.removeLoader()
                        cell.removeBlurView()
                        cell.imageView.image = UIImage(data: data!)
                    }
                } else {
                    ai.removeLoader()
                    cell.removeBlurView()
                }
            })
            
            
        }
        return cell
    }
    
}

// MARK: FETCH RESULT CONTROLLER DELEGATE
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
