//
//  PhotoAlbumLayout.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/27/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class PhotoAlbumLayout: UICollectionViewFlowLayout {
  
    @IBOutlet weak var photosView: UICollectionView!
    let innerSpace: CGFloat = 3.0
    let numberOfCellsOnRow: CGFloat = 3
    
    override init() {
        super.init()
        self.minimumLineSpacing = innerSpace
        self.minimumInteritemSpacing = innerSpace
        self.scrollDirection = .vertical
        let dimension = (photosView.frame.size.width - (2 * innerSpace)) / 3.0
        self.itemSize = CGSize(width: dimension, height: dimension)
    }
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
 
}
