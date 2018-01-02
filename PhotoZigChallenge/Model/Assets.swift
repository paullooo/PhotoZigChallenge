//
//  Assets.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class AssetsResponse: Object, Mappable {
    
    //Realizei o mapeamento da url tbm para caso ela fosse alterada não alterar o funcionamento.
    @objc dynamic var assetsLocation = ""
    let assets = List<Asset>()
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        assetsLocation <- map["assetsLocation"]
        var array :[Asset] = []
        array <- map["objects"]
        
        for asset in array {
            self.assets.append(asset)
        }
    }
}

class Subtitle: Object, Mappable {
    @objc dynamic var text = ""
    @objc dynamic var time = 0.0
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        text <- map["txt"]
        time <- map["time"]
    }
}

class Asset: Object, Mappable {
    @objc dynamic var name = ""
    @objc dynamic var backgroungVideo = ""
    @objc dynamic var imageThumb = ""
    @objc dynamic var soundFile = ""
    let subtitles = List<Subtitle>()
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        name <- map["name"]
        backgroungVideo <- map["bg"]
        imageThumb <- map["im"]
        soundFile <- map["sg"]
        
        var array :[Subtitle] = []
        array <- map["txts"]
        
        for subtitle in array {
            self.subtitles.append(subtitle)
        }
    }
}



