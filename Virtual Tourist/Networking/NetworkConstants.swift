//
//  NetworkConstants.swift
//  Virtual Tourist
//
//  Created by Saud Alhelali on 02/02/2019.
//  Copyright © 2019 Saud Alhelali. All rights reserved.
//

import Foundation

extension Network {
    
    struct API {
        static let Schema = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
        
        static let SearchBBoxHalfWidth = 0.2
        static let SearchBBoxHalfHeight = 0.2
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    struct APIParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let BoundingBox = "bbox"
        static let PhotosPerPage = "per_page"
        static let Page = "page"
    }
    
    struct APIParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "49b11870618aa6e0cbad501692ee9906"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_n"
        static let PhotosPerPage = 15
    }
}
