//
//  PhotoSelectorHeader.swift
//  Instagram
//
//  Created by Sovorn on 9/29/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

class PhotoSelectorHeader: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
