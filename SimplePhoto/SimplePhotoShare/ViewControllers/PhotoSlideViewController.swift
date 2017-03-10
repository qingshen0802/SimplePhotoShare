//
//  PhotoSlideViewController.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/4/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoSlideViewController: UIPageViewController, UIPageViewControllerDataSource, PhotoContentViewActionDelegate {
    
    var photos: Results<PhotoModel>!
    var currentPhotoIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.setViewControllers([getViewControllerAtIndex(currentPhotoIndex)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
    
    // MARK:- UIPageViewControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! PhotoSliderContentViewController
        var index = pageContent.pageIndex
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        index -= 1;
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! PhotoSliderContentViewController
        
        var index = pageContent.pageIndex
        
        if (index == NSNotFound) {
            return nil;
        }
        index += 1;
        if (index == photos.count) {
            return nil;
        }
        return getViewControllerAtIndex(index)
    }
    
    // Initialize child viewcontrollers with images
    func getViewControllerAtIndex(_ index: NSInteger) -> PhotoSliderContentViewController {
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoslidercontentview") as! PhotoSliderContentViewController        
        pageContentViewController.photoModel = photos[index]
        pageContentViewController.pageIndex = index
        pageContentViewController.totalCount = photos.count
        pageContentViewController.actionDelegate = self
        
        return pageContentViewController
    }
    
    // MARK: PhotoContentAction Delegate
    func deletePhoto(index: Int) {
        DBUtil.sharedUtil.removePhoto(photoModel: photos[index])
        if index == photos.count {
            self.setViewControllers([getViewControllerAtIndex(index - 1)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        } else {
            self.setViewControllers([getViewControllerAtIndex(index + 1)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
    }
}
