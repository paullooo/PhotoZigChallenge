//
//  RequestFactory.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import Foundation
import Alamofire

let baseURL = "http://pbmedia.pepblast.com/pz_challenge/"

class RequestFactory {
    static func getAssets() -> DataRequest {
        return Alamofire.request(baseURL + "assets.json", method: .get)
    }
}
