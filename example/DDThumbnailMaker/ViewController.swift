//
//  ViewController.swift
//  DDThumbnailMaker
//
//  Created by moxieDani on 02/24/2023.
//  Copyright (c) 2023 moxieDani. All rights reserved.
//

import UIKit
import DDThumbnailMaker

class ViewController: UIViewController {

    var imageView = UIImageView()
    var thumbnailImageWidth = CGFloat(192)
    var thumbnailImageHeight = CGFloat(144)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imageView.frame = CGRectMake((self.view.frame.size.width / 2) - (self.thumbnailImageWidth / 2),
                                          (self.view.frame.size.height / 2) - (self.thumbnailImageHeight / 2),
                                          self.thumbnailImageWidth,
                                          self.thumbnailImageHeight);
        self.view.addSubview(imageView)
        let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "mp4") ?? "")
        let thumbnailMaker = DDThumbnailMaker.init(videoURL)
        thumbnailMaker.thumbnailImageSize = CGSize(width: <width>, height: <height>)
        thumbnailMaker.intervalMsec = 1000
        thumbnailMaker.intervalFrame = 60
        thumbnailMaker.generate { requestedTime, image, actualTime, result, error in
            if result == .succeeded {
                let img = UIImage(cgImage: image!)
                DispatchQueue.main.async {
                    self.imageView.image = img
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

