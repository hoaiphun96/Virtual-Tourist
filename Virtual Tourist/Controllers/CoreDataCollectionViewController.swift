//
//  CoreDataCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/26/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit
import CoreData
class CoreDataCollectionViewController: UICollectionViewController {
    
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchResultsController?.delegate = self as NSFetchedResultsControllerDelegate
            executeSearch()
            collectionView!.reloadData()
        }
    }
    
    init(fetchResultController fc : NSFetchedResultsController<NSFetchRequestResult>, layout: PhotoAlbumLayout) {
        fetchResultsController = fc
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - CoreDataCollectionViewController (Subclass Must Implement)

extension CoreDataCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionViewController")
    }
}

// MARK: - CoreDataTableViewController (Table Data Source)

extension CoreDataCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
}

// MARK: - CoreDataTableViewController (Fetches)

extension CoreDataCollectionViewController {
    
    func executeSearch() {
        if let fc = fetchResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchResultsController))")
            }
        }
    }
}

// MARK: - CoreDataCollectio ViewController: NSFetchedResultsControllerDelegate

extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
    //TO DO: IMPLEMENT THIS
}


