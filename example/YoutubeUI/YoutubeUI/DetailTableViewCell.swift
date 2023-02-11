//
//  DetailTableViewCell.swift
//  YoutubeUI
//
//  Created by Daniel on 2023/02/10.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(video: Video) {
        title.text = video.title
        shortDescription.text = video.shortDescription
        img.load1(url: video.image_url)
   }

}

extension UIImageView {
    func load1(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

