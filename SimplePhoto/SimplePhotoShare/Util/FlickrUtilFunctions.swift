//
//  FlickrUtilFunctions.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/3/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import Foundation
import FlickrKit

enum ACTION_TYPE {
    case NEW_LOGIN
    case LOGIN
    case GET_PHOTOS
}

enum RESULT {
    case SUCCESS
    case FAILED
}

protocol FlickrUtilDelegate {
    func responseFromFlickr(type: ACTION_TYPE, result: RESULT, data: Any!)
}

// A util class for Flickr API
class FlickrUtilFunctions {
    
    static let sharedFlickrUtil = FlickrUtilFunctions()
    
    var fDelegate: FlickrUtilDelegate!
    var completeAuthOp: FKDUNetworkOperation!
    var checkAuthOp: FKDUNetworkOperation!
    
    var userId: String!
    
    // Check if user already authorized with Flickr in the app
    func checkFlickrAuthentication() {
        
        self.checkAuthOp = FlickrKit.shared().checkAuthorization(onCompletion: { (userName, userId, fullName, error) in
            if ((error == nil)) {
                self.userId = userId
                if self.fDelegate != nil {
                    self.fDelegate.responseFromFlickr(type: .LOGIN, result: .SUCCESS, data: nil)
                }
            } else {                
                if self.fDelegate != nil {
                    self.fDelegate.responseFromFlickr(type: .LOGIN, result: .FAILED, data: error?.localizedDescription)
                }
            }
        })
    }
    
    // If the user is not authorized with Flickr, it will attempt to login with Flickr
    func attemptFlickrAuthentication(url: URL) {
        
        self.completeAuthOp = FlickrKit.shared().completeAuth(with: url, completion: { (userName, userId, fullName, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    self.userId = userId
                    if self.fDelegate != nil {
                        self.fDelegate.responseFromFlickr(type: .NEW_LOGIN, result: .SUCCESS, data: nil)
                    }
                } else {
                    if self.fDelegate != nil {
                        self.fDelegate.responseFromFlickr(type: .NEW_LOGIN, result: .FAILED, data: error?.localizedDescription)
                    }
                }
            });
        })
    }
    
    // Get photos of users authorized in the app
    func getPhotoFromStream(pageNumber: Int) {
        var flickrPhotos = [FlickrPhotoModel]()
            // Get user's photos from his Flickr account. can get 15 photos per call.        
        FlickrKit.shared().call("flickr.photos.search", args: ["user_id": self.userId!, "per_page": "15", "page": "\(pageNumber)" ] , maxCacheAge: FKDUMaxAge.neverCache, completion: { (response, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if let response = response, let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                    for photoDictionary in photoArray {
                        let model = FlickrPhotoModel()
                        // Get thumbnail url for photo to show instant display
                        model.thumbUrl = FlickrKit.shared().photoURL(for: FKPhotoSize.thumbnail100, fromPhotoDictionary: photoDictionary)
                        // Get big photo url for photo to show detailed display
                        model.originalUrl = FlickrKit.shared().photoURL(for: FKPhotoSize.large1024, fromPhotoDictionary: photoDictionary)
                        flickrPhotos.append(model)
                    }
                    if self.fDelegate != nil {
                        self.fDelegate.responseFromFlickr(type: .GET_PHOTOS, result: .SUCCESS, data: flickrPhotos)
                    }
                } else {
                    self.fDelegate.responseFromFlickr(type: .GET_PHOTOS, result: .FAILED, data: error)
                }
            })
        })
    }
}
