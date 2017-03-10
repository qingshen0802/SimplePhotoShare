//
//  DBUtil.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/4/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import Foundation
import RealmSwift

// A util class to manage database with RealmSwift
class DBUtil {
    
    static let sharedUtil = DBUtil()
    
    let realm = try! Realm()
    
    func readAllPhotos() -> Results<PhotoModel> {
        return realm.objects(PhotoModel.self)
    }
    
    func addNewPhoto(photoModel: PhotoModel) {
        try! realm.write {
            photoModel.id = incrementID()
            realm.add(photoModel)
        }
    }
    
    func updatePhoto(photoModel: PhotoModel) {
        let temp = realm.objects(PhotoModel.self).filter("id == \(photoModel.id)").first
        try! realm.write {
            temp?.image = photoModel.image
        }
    }
    
    func removePhoto(photoModel: PhotoModel) {
        try! realm.write {
            realm.delete(photoModel)
        }
    }
    
    func removeAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func incrementID() -> Int {
        return (realm.objects(PhotoModel.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
