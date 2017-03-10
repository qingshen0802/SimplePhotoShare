//
//  FlickrPhotoViewController.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/3/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import UIKit

protocol GetFlickrPhotoDelegate {
    func setPhotoFromFlickr(model: FlickrPhotoModel)
}

class FlickrPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, FlickrUtilDelegate {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var progressDg: UIActivityIndicatorView!
    
    var photoModels = [FlickrPhotoModel]()
    var pageNumber = 1
    var canLoadMore = true
    var cellWidth: CGFloat!
    var getFlickrPhotoDelegate: GetFlickrPhotoDelegate!
    
    override func viewWillAppear(_ animated: Bool) {
        // Before display view, the app check if the user logged in with Flickr and let him know to login with Flickr if he want to browse photos from Flickr
        FlickrUtilFunctions.sharedFlickrUtil.fDelegate = self
        FlickrUtilFunctions.sharedFlickrUtil.checkFlickrAuthentication()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        progressDg.startAnimating()
        progressDg.isHidden = false
        
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
        
        photoCollectionView.reloadData()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell_flickr", for: indexPath) as! PhotoCollectionCell
        cell.imageView.sd_setImage(with: photoModels[indexPath.row].thumbUrl, placeholderImage: UIImage(named: "flickr_icon"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if getFlickrPhotoDelegate != nil {
            getFlickrPhotoDelegate.setPhotoFromFlickr(model: photoModels[indexPath.row])
        }        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // MARK: UIScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height && canLoadMore) {
            FlickrUtilFunctions.sharedFlickrUtil.getPhotoFromStream(pageNumber: pageNumber)
        }
    }
    // MARK: FlickrUtil Delegate
    func responseFromFlickr(type: ACTION_TYPE, result: RESULT, data: Any!) {
        // Response for new user log in, it will call API to get photos if it success
        if type == .NEW_LOGIN {
            _ = self.navigationController?.popViewController(animated: true)
            if result == .SUCCESS {
                FlickrUtilFunctions.sharedFlickrUtil.getPhotoFromStream(pageNumber: pageNumber)
            } else {
                progressDg.isHidden = true
                _ = self.navigationController?.popToViewController(self, animated: true)
                let alert = UIAlertController(title: "Flickr Login Failed", message: data as? String, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        // Response for checking stored user. if there's token for user already, it will call API to get photos
        if type == .LOGIN {
            if result == .SUCCESS {
                FlickrUtilFunctions.sharedFlickrUtil.getPhotoFromStream(pageNumber: pageNumber)
            } else {
                // if there's no stored token for flickr user, it will go to login view
                self.navigationController?.pushViewController(self.storyboard?.instantiateViewController(withIdentifier: "flickrloginview") as! FlickrLogInViewController, animated: true)
            }
        }
        // Response for getting photos from API call
        if type == .GET_PHOTOS {
            if result == .SUCCESS {
                progressDg.isHidden = true
                let photos = data as! [FlickrPhotoModel]
                if photos.count > 0 {
                    for item in photos {
                        self.photoModels.append(item)
                    }
                    pageNumber += 1
                } else {
                    canLoadMore = false
                }
            } else {
                let alert = UIAlertController(title: "Error", message: data as? String, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        photoCollectionView.reloadData()
    }
}
