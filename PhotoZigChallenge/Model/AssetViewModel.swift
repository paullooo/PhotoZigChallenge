//
//  AssetViewModel.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import Foundation
import Alamofire

struct AssetView {
    var name = ""
    var videoURL = ""
    var imageThumb = ""
    var audioURL = ""
    var videoName = ""
    var audioName = ""
    var subtitles:[SubtitleView] = []
}

struct SubtitleView {
    var text = ""
    var time = ""
}

class AssetViewModel {
    
    static func getLocalURL(fileName: String) -> URL {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL
    }
    
    static func getAssets() -> [AssetView] {
        var assets: [AssetView] = []
        
        if let response = uiRealm.objects(AssetsResponse.self).first {
            let baseURL = response.assetsLocation
            for assetBD in response.assets {
                var assetObject = AssetView()
                assetObject.imageThumb = "\(baseURL)/\(assetBD.imageThumb)"
                assetObject.name = assetBD.name
                assetObject.videoURL = "\(baseURL)/\(assetBD.backgroungVideo)"
                assetObject.audioURL = "\(baseURL)/\(assetBD.soundFile)"
                assetObject.videoName = assetBD.backgroungVideo
                assetObject.audioName = assetBD.soundFile
                
                for subtitle in assetBD.subtitles {
                    var subtitleView = SubtitleView()
                    subtitleView.text = subtitle.text
                    subtitleView.time = String(format: "%.1f", subtitle.time)
                    assetObject.subtitles.append(subtitleView)
                }
                
                assets.append(assetObject)
            }
        }
        return assets
    }
}

