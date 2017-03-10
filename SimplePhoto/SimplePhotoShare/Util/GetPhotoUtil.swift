//
//  GetPhoto.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/3/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

enum MEDIA_TYPE {
    case PHOTO
    case FLICKR
}

protocol GetPhotoUtilDelegate{
    func setImage(image: UIImage!, mediaType: MEDIA_TYPE)
}
// A util class for getting photos from Camera, Photo Library and Flickr API
class GetPhotoUtil: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pDelegate: GetPhotoUtilDelegate!
    var parentController: UIViewController!
    
    func inite(viewController: UIViewController) {
        self.view.backgroundColor = UIColor(red: 132.0/255.0, green: 233.0/255.0, blue: 245.0/255.0, alpha: 0.7)
        self.view.alpha = 0.5
        self.parentController = viewController
    }
    
    // Check if Camera feature and photo library is available and attempt to them
    func takePhoto (){
        
        let cameraDeviceAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        let photoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        
        let alertController = UIAlertController(title: "Choose photo from...", message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = parentController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: parentController.view.frame.maxX, y: 68, width: 1.0, height: 1.0)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {(cameraAction) in
            self.shouldStartCameraController()
        })
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {(libraryAction) in
            self.shouldStartPhotoLibraryPickerController()
        })
        let flickrAction = UIAlertAction(title: "Flickr", style: .default, handler: {(flickrAction) in
            self.parentController.dismiss(animated: false, completion: nil)
            self.pDelegate.setImage(image: nil, mediaType: MEDIA_TYPE.FLICKR)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if cameraDeviceAvailable {
            alertController.addAction(cameraAction)
        }
        if photoLibraryAvailable {
            alertController.addAction(libraryAction)
        }
        alertController.addAction(flickrAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Check if front and rear camera device and open default Camera UI supported by OS.
    func shouldStartCameraController()  {
        let cameraUI = UIImagePickerController()
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true && UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera)?.contains(kUTTypeImage as String) == true){
            cameraUI.mediaTypes = NSArray(array: [kUTTypeImage]) as! [String]
            cameraUI.sourceType = UIImagePickerControllerSourceType.camera
            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) == true {
                cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front) == true{
                cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.front
            }
        } else {
            return
        }
        
        cameraUI.showsCameraControls = true
        cameraUI.delegate = self
        self.parentController.present(cameraUI, animated: true, completion: nil)
    }
    
    // Open photo library
    func shouldStartPhotoLibraryPickerController() {
        let cameraUI = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == true && UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.photoLibrary)?.contains(kUTTypeImage as String) == true {
            cameraUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
            cameraUI.mediaTypes = NSArray(array: [kUTTypeImage]) as! [String]
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) == true && UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.savedPhotosAlbum)?.contains(kUTTypeImage as String) == true {
            cameraUI.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            cameraUI.mediaTypes = NSArray(array: [kUTTypeImage]) as! [String]
        } else {
            return
        }
        cameraUI.delegate = self
        self.parentController.present(cameraUI, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerController Delegates
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.parentController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.parentController.dismiss(animated: false, completion: nil)
        self.pDelegate.setImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage, mediaType: .PHOTO)
    }
}
