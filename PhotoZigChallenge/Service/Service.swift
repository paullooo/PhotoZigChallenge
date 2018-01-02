//
//  Service.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireObjectMapper


protocol ResponseDelegate {
    func success(_ type: ResponseType)
    func failure(_ type: ResponseType, error: Error?)
}

class Service: BaseService {
    let delegate: ResponseDelegate
    private var resumeData: Data?
    //private var isDonwloading:Bool?
    
    required init(delegate: ResponseDelegate) {
        self.delegate = delegate
    }
    
    func getAssets() {
        RequestFactory.getAssets().validate().responseObject { (response: DataResponse<AssetsResponse>) in
            switch response.result {
            case .success:
                if let responseData = response.result.value {
                    try! uiRealm.write {
                        uiRealm.deleteAll()
                    }
                    try! uiRealm.write {
                        uiRealm.add(responseData)
                    }
                    self.delegate.success(.assets)
                }
            case .failure:
                self.delegate.failure(.assets, error: self.getError(response: response))
            }
        }
    }
    
    func fileDownload(downloadName:String,downloadURL:String, type: ResponseType){
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (AssetViewModel.getLocalURL(fileName: downloadName), [.removePreviousFile, .createIntermediateDirectories])
        }
        let request: DownloadRequest
        if let resumeData = resumeData {
            request = Alamofire.download(resumingWith: resumeData)
        } else {
            request = Alamofire.download(downloadURL, to: destination)
        }
        request.responseData { response in
            switch response.result {
            case .success(let data):
                self.delegate.success(type)
            case .failure:
                self.delegate.failure(type, error: nil)
                self.resumeData = response.resumeData
            }
        }
    }
    
    func stopFileDownload() {
            let sessionManager = Alamofire.SessionManager.default
            sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            }
            print("Download cancelado")
        }
    
}

