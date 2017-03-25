//
//  CameraView.swift
//  studio-plus
//
//  Created by Lindsay Pond on 3/25/17.
//  Copyright © 2017 Lindsay Angela Ena. All rights reserved.
//

import UIKit

class CameraView: UIView {
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var thumbnail: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    
    @IBOutlet weak var switchCameraButton: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "Camera", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    @IBAction func switchCameras(_ sender: AnyObject) {
        switchCameras?()
    }

    var switchCameras: (()-> Void)?
    
    @IBAction func toggleHint(_ sender: UIButton) {
        hintButton.isSelected = !hintButton.isSelected
    }
    
    func configure(brandAssets: CameraBrandAssets) {
        if let defaultImage =  UIImage(named: brandAssets.hintImageDefaultName) {
            hintButton.setImage(defaultImage, for: .normal)

        }
        if let selectedImage =  UIImage(named: brandAssets.hintImageActivatedName) {
            hintButton.setImage(selectedImage, for: .selected)
        }
        
        
    }
}
