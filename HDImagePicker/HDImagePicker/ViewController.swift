//
//  ViewController.swift
//  HDImagePicker
//
//  Created by Dang Nguyen on 7/5/16.
//  Copyright © 2016 1Action. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var labelPicking: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        HDImagePicker.showImagePickerFromVC(self, allowsEditing: true) { [weak self] (originImage: UIImage?, editedImage: UIImage?) in
            
            if let _image = originImage {
                self?.imageView.image = _image
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

