//
//  WBBImagePicker.swift
//  1Action
//
//  Created by Dang Nguyen on 7/4/16.
//  Copyright © 2016 AnG. All rights reserved.
//

import UIKit
import MobileCoreServices

typealias HDImagePickerCompleteBlock = (originImage: UIImage?, editedImage: UIImage?) -> Void

class HDImagePicker: NSObject {
    
    static let sharedInstance = HDImagePicker()
    private override init() {
        super.init()
    }
    
    private var imagePickerController = UIImagePickerController()
    private var completeBlock: HDImagePickerCompleteBlock?
    
    var actionSheetTitle: String?                  = "Picking Options"
    var actionSheetMessage: String?
    var actionSheetOptionCamera: String?           = "Camera"
    var actionSheetOptionCameraRoll: String?       = "Library"
    var actionSheetOptionPhotoLibrary: String?     = "Photo Library"
    var actionSheetOptionCancel: String?           = "Cancel"
    
    //  MARK: UTILS
    /// ----------------------------------------------------------------------------------
    class func isCameraSourceAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    class func isCameraRollSourceAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)
    }
    class func isPhotoLibrarySourceAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
    }
    
    //  MARK: ACTIONS
    /// ----------------------------------------------------------------------------------
    class func showImagePickerFromVC(viewController: UIViewController, allowsEditing: Bool, onComplete: HDImagePickerCompleteBlock?) {
        
        /// Options
        var actions: [(String?, () -> Void)] = []
        if self.isCameraSourceAvailable() {
            actions.append((self.sharedInstance.actionSheetOptionCamera, {
                self.takeImageFromVC(viewController, allowsEditing: allowsEditing, onComplete: onComplete)
            }))
        }
        actions.append((self.sharedInstance.actionSheetOptionCameraRoll, {
            self.pickImageFromVC(viewController, allowsEditing: allowsEditing, onComplete: onComplete)
        }))
        
        /// Action sheet
        let alertController = UIAlertController(
            title: self.sharedInstance.actionSheetTitle,
            message: self.sharedInstance.actionSheetMessage,
            preferredStyle: .ActionSheet)
        
        for actionInfo in actions {
            alertController.addAction(UIAlertAction(title: actionInfo.0, style: .Default, handler: { (action: UIAlertAction) in
                actionInfo.1()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: self.sharedInstance.actionSheetOptionCancel, style: .Cancel, handler: { (action: UIAlertAction) in
            onComplete?(originImage: nil, editedImage: nil)
        }))
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    class func pickImageFromVC(viewController: UIViewController, allowsEditing: Bool, onComplete: HDImagePickerCompleteBlock?) {
        
        self.sharedInstance.showImagePickerWithSource(.SavedPhotosAlbum, fromVC: viewController, allowsEditing: allowsEditing, onComplete: onComplete)
    }
    class func takeImageFromVC(viewController: UIViewController, allowsEditing: Bool, onComplete: HDImagePickerCompleteBlock?) {
        
        var sourceType = UIImagePickerControllerSourceType.Camera
        if !self.isCameraSourceAvailable() {
            sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        }
        
        self.sharedInstance.showImagePickerWithSource(sourceType, fromVC: viewController, allowsEditing: allowsEditing, onComplete: onComplete)
    }
    
    //  MARK: PRIVATE ACTIONS
    /// ----------------------------------------------------------------------------------
    private func showImagePickerWithSource(sourceType: UIImagePickerControllerSourceType, fromVC: UIViewController, allowsEditing: Bool, onComplete: HDImagePickerCompleteBlock?) {
        
        self.completeBlock = onComplete
        
        let imagePickerController = self.imagePickerController
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = allowsEditing
        
        fromVC.presentViewController(self.imagePickerController, animated: true, completion: nil)
    }
}

/// ----------------------------------------------------------------------------------
//  MARK: - IMAGE PICKER DELEGATE
/// ----------------------------------------------------------------------------------
extension HDImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.imagePickerController.dismissViewControllerAnimated(true, completion: { [weak self] in
            self?.completeBlock?(originImage: nil, editedImage: nil)
            self?.completeBlock = nil
            })
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let _mediaType = info[UIImagePickerControllerMediaType] as? String else {
            
            self.imagePickerController.dismissViewControllerAnimated(true, completion: { [weak self] in
                self?.completeBlock?(originImage: nil, editedImage: nil)
                self?.completeBlock = nil
            })
            return
        }
        guard _mediaType == (kUTTypeImage as String) else {
            self.imagePickerController.dismissViewControllerAnimated(true, completion: { [weak self] in
                self?.completeBlock?(originImage: nil, editedImage: nil)
                self?.completeBlock = nil
                })
            return
        }
        
        let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.imagePickerController.dismissViewControllerAnimated(true, completion: { [weak self] in
            self?.completeBlock?(originImage: originalImage, editedImage: editedImage)
            self?.completeBlock = nil
            })
    }
}
