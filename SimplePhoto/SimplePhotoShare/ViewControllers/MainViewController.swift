//
//  MainViewController.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/3/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import UIKit
import FlickrKit
import RealmSwift

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GetPhotoUtilDelegate,  GetFlickrPhotoDelegate {

    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    let photoUtil = GetPhotoUtil()
    var isLoadingImage = false
    var photoFromDB: Results<PhotoModel>!
    var cellWidth: CGFloat!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize photo util class
        photoUtil.inite(viewController: self)
        photoUtil.pDelegate = self
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        // Calculate photo cell size based on width of screen
        let viewSize: CGRect = UIScreen.main.bounds
        let width = viewSize.width
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        // 2. check the idiom
        switch (deviceIdiom) {
            case .pad:
                cellWidth = (width - 12 * 4 - 16)/5
                break
            case .phone:
                cellWidth = (width - 12 * 2 - 16)/3
                break
            default:
                break
        }
        
        photoFromDB = DBUtil.sharedUtil.readAllPhotos()
        photoCollectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        photoCollectionView.reloadData()
    }
    
    @IBAction func tapNew(_ sender: UIButton) {
        self.addChildViewController(photoUtil)
        photoUtil.takePhoto()
    }
    
    func addPhotoToDB(image: UIImage) {
        let photo = PhotoModel()
        photo.image = NSData(data: UIImageJPEGRepresentation(image, 1.0)!)
        DBUtil.sharedUtil.addNewPhoto(photoModel: photo)
    }
    
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoadingImage {
            return photoFromDB.count + 1
        } else {
            return photoFromDB.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingImage {
            if indexPath.row == photoFromDB.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingcell", for: indexPath)
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 4
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = UIColor.white.cgColor
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! PhotoCollectionCell
                cell.imageView.image = UIImage(data: photoFromDB[indexPath.row].image as Data)
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! PhotoCollectionCell
            cell.imageView.image = UIImage(data: photoFromDB[indexPath.row].image as Data)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoSliderViewController = self.storyboard?.instantiateViewController(withIdentifier: "photosliderview") as! PhotoSlideViewController
        photoSliderViewController.photos = self.photoFromDB
        photoSliderViewController.currentPhotoIndex = indexPath.row
        self.navigationController?.pushViewController(photoSliderViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // MARK: GetPhotoUtil Delegate
    func setImage(image: UIImage!, mediaType: MEDIA_TYPE) {
        if mediaType == .FLICKR {
            //Get photos from flickr
            let flickrPhotoViewController = self.storyboard?.instantiateViewController(withIdentifier: "flickrphotoview") as! FlickrPhotoViewController
            flickrPhotoViewController.getFlickrPhotoDelegate = self
            self.navigationController?.pushViewController(flickrPhotoViewController, animated: true)
        } else {
            if image != nil {
                addPhotoToDB(image: image)
                photoCollectionView.reloadData()
            }
        }
    }
    
    // MARK: GetFlickrPhoto Delegate
    func setPhotoFromFlickr(model: FlickrPhotoModel) {
        let request = URLRequest(url: model.originalUrl)
        isLoadingImage = true
        self.photoCollectionView.reloadData()
        // Get full photo from big url of Flickr photo
        NSURLConnection.sendAsynchronousRequest(request, queue: .main) { (response, data, error) in
            if error == nil {
                self.isLoadingImage = false
                self.addPhotoToDB(image: UIImage(data: data!)!)
                self.photoCollectionView.reloadData()
            } else {
                self.isLoadingImage = false
                let alert = UIAlertController(title: "Flickr Photo", message: "Failed load image from Flickr", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (cancelAction) in
                    self.photoCollectionView.reloadData()
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
