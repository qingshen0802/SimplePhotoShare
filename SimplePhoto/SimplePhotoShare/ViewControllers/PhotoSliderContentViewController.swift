//
//  PhotoSliderContentViewController.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/4/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import UIKit
import CLImageEditor
import Social

protocol PhotoContentViewActionDelegate {
    func deletePhoto(index: Int)
}

class PhotoSliderContentViewController: UIViewController, UIScrollViewDelegate, CLImageEditorDelegate {

    @IBOutlet weak var backScrollView: UIScrollView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var photoModel: PhotoModel!
    var pageIndex: Int = 0
    var totalCount: Int = 0
    var actionDelegate: PhotoContentViewActionDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backScrollView.minimumZoomScale = 1.0
        backScrollView.maximumZoomScale = 6.0
        backScrollView.delegate = self
        
        contentImageView.image = UIImage(data: photoModel.image as Data)
        titleLabel.text = "\(pageIndex + 1) of \(totalCount)"
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        let clImageEditor = CLImageEditor(image: contentImageView.image, delegate: self)
        self.present(clImageEditor!, animated: true, completion: nil)
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tapDelete(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Are you sure?", message: "Photo will be deleted.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (confirmAction) in
            if self.actionDelegate != nil {
                self.actionDelegate.deletePhoto(index: self.pageIndex)
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        deleteAlert.addAction(confirmAction)
        deleteAlert.addAction(cancelAction)
        present(deleteAlert, animated: true, completion: nil)
    }
    
    // Display Actionsheet for Sharing.
    // Used Social framework that supported by Apple. If you want to change it with SDKs that supported by Facebook and Twitter, I can update it with them.
    @IBAction func tapShare(_ sender: UIButton) {
        let shareAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        shareAlert.popoverPresentationController?.sourceView = sender
        // Facebook share
        let fbShare = UIAlertAction(title: "Facebook", style: .default, handler: {(fbShare) in
            let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
            vc?.add(self.contentImageView.image)
            vc?.setInitialText("Facebook share.")
            self.present(vc!, animated: true, completion: nil)
        })
        // Twitter Share
        let twitterShare = UIAlertAction(title: "Twitter", style: .default, handler: {(twitterShare) in
            let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
            vc?.add(self.contentImageView.image)
            vc?.setInitialText("Twitter share.")
            self.present(vc!, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        shareAlert.addAction(fbShare)
        shareAlert.addAction(twitterShare)
        shareAlert.addAction(cancelAction)
        present(shareAlert, animated: true, completion: nil)
    }
    
    // MARK: UIScrollView Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    
    // MARK: CLImageEditor Delegate
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        // Get edited photo and replace with original photo
        contentImageView.image = image
        let model = PhotoModel()
        model.id = photoModel.id
        model.image = NSData(data: UIImageJPEGRepresentation(image, 1.0)!)
        DBUtil.sharedUtil.updatePhoto(photoModel: model)
        editor.dismiss(animated: true, completion: nil)
    }
}
