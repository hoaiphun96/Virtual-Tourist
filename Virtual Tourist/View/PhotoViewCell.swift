//
//  photoViewCell.swift
//  Virtual Tourist
//
//  Created by Jamie Nguyen on 12/27/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var blurView: UIVisualEffectView?
    
    func addBlurView(){
        DispatchQueue.main.async {
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            self.blurView?.alpha = 0.5
            self.blurView?.frame = self.imageView.bounds
            self.blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.imageView.addSubview(self.blurView!)
        }
    }
    
    func removeBlurView(){
        blurView?.removeFromSuperview()
    }
}
