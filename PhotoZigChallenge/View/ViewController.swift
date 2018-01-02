//
//  ViewController.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var assetsArray: [AssetView] = []

    @IBOutlet var tableView: UITableView!
    var service: Service!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.register(UINib(nibName: "AssetTableTableViewCell", bundle: nil), forCellReuseIdentifier: "assetsCell")
        self.service = Service(delegate: self)
        service.getAssets();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageControll" {
            if let controller = segue.destination as? PageViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    controller.selectedIndex = indexPath.row
                    controller.assetsArray = assetsArray
                }
            }
        }
    }
}

extension ViewController: ResponseDelegate {
    func success(_ type: ResponseType) {
        if type == .assets{
            self.assetsArray = AssetViewModel.getAssets()
            self.tableView.reloadData()
        }
    }
    
    func failure(_ type: ResponseType, error: Error?) {
        
        if let erro = error as NSError? {
            let tipo = erro.userInfo["type"] as! APIError
            
            let alert = UIAlertController(title: "Algo deu errado", message: tipo.description, preferredStyle: .alert)
            let fecharAction = UIAlertAction(title: "Fechar", style: .default, handler: nil)
            alert.addAction(fecharAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetsArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetsCell", for:indexPath) as! AssetTableTableViewCell
        let asset = assetsArray[indexPath.row]
        cell.bind(name: asset.name, imageURL: asset.imageThumb)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "pageControll", sender: nil)
    }
}


