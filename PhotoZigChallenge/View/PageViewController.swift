//
//  PageViewController.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import UIKit
import Foundation

class PageViewController: UIPageViewController {
    var selectedIndex: NSInteger = 0
    var assetsArray: [AssetView] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.setViewControllers([getViewControllerAtIndex(selectedIndex)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let detailController = viewController as! DetailViewController
        var index = detailController.pageIndex
        if index == 0 || index == NSNotFound {
            return nil
        }
        index = index - 1
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let detailController = viewController as! DetailViewController
        var index = detailController.pageIndex
        if index == NSNotFound {
            return nil
        }
        index = index + 1
        if index == assetsArray.count {
            return nil
        }
        return getViewControllerAtIndex(index)
    }
    
    func getViewControllerAtIndex(_ index: NSInteger) -> DetailViewController {
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailController.assetView = assetsArray[index]
        detailController.pageIndex = index
        return detailController
    }
}
