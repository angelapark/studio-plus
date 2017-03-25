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
    @IBOutlet weak var flashLabel: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "Camera", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
