//
//  PhotosParser.swift
//  Virtual Tourist
//
//  Created by Saud Alhelali on 02/02/2019.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//

import Foundation

struct PhotosParser: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let pages: Int
    let photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}
