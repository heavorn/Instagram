//
//  PreviewPhotoContainerView.swift
//  Instagram
//
//  Created by Sovorn on 10/4/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let preViewImage: UIImageView = {
        let iv = UIImageView()
        
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "cancel_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "save_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        return button
    }()
    
    
    @objc func handleCancel(){
        self.removeFromSuperview()
    }
    
    @objc func handleSave(){
        let library = PHPhotoLibrary.shared()
        guard let previewImage = preViewImage.image else {return}
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, error) in
            if (error != nil){
                print("Cannot save to library", error!)
                return
            }
            
            DispatchQueue.main.async {
                let saveLabel = UILabel()
                saveLabel.text = "Save Successfully"
                saveLabel.textColor = .white
                saveLabel.font = UIFont.boldSystemFont(ofSize: 16)
                saveLabel.numberOfLines = 0
                saveLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                saveLabel.textAlignment = .center
                
                saveLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                saveLabel.center = self.center
                self.addSubview(saveLabel)
                
                saveLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        saveLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        saveLabel.alpha = 0
                    }, completion: { (_) in
                        saveLabel.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(preViewImage)
        addSubview(cancelButton)
        addSubview(saveButton)
        preViewImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
