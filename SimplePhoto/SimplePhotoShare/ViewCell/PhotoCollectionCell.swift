//
//  PhotoCollectionCell.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/3/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    // Make Photo cells rounded and bordered with white color
    func initialize() {
        let layer = self.layer as CALayer
        layer.masksToBounds = true
        layer.cornerRadius = 4
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor        
    }
}
