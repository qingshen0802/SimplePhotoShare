//
//  PhotoModel.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/4/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import Foundation
import RealmSwift

// Realm model for Photos, save images as NSData to database
class PhotoModel: Object {
    dynamic var id = 0
    dynamic var image: NSData!
}
