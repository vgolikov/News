//
//  NewsTableViewCell.swift
//  News
//
//  Created by Viachaslau Holikau on 7/9/20.
//  Copyright © 2020 Viachaslau Holikau. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showMoreButton.isHidden = true
    }
    
    override func prepareForReuse() {
        self.newsImage.image = nil
        self.titleLabel.text = ""
        self.descriptionLabel.text = ""
    }
    
    func setupCell(news: News) {
        if let imageUrl = news.imageUrl, let url = URL(string: imageUrl) {
            self.newsImage.load(url: url)
        } else {
            self.newsImage.image = UIImage(named: "no-image")
        }
        
        self.titleLabel.text = news.title
        self.descriptionLabel.text = news.description
        
        showMoreButton.isHidden = descriptionLabel.calculateLines() <= 3
    }
    
}
