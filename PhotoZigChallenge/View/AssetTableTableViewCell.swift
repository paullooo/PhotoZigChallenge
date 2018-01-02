//
//  AssetTableTableViewCell.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import UIKit
import Kingfisher

class AssetTableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var assetName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(name:String, imageURL: String) {
        
        assetName.text = name
        assetImage.kf.setImage(with: URL(string: imageURL))
    }
}
