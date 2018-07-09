//
//  ImagesTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/19/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

class ImagesTableViewCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var scrolMain: UIScrollView!
    @IBOutlet weak var pageContr: UIPageControl!
    
    var images = [Image]() 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        loadScrollView(fake: true)
    }
    
    func loadScrollView(fake: Bool) {
        let pageCount = CGFloat(images.count)
        
        scrolMain.backgroundColor = UIColor.clear
        scrolMain.delegate = self
        scrolMain.isPagingEnabled = true
        scrolMain.contentSize = CGSize(width: scrolMain.frame.size.width * pageCount, height: scrolMain.frame.size.height)
        scrolMain.showsHorizontalScrollIndicator = false
        pageContr.numberOfPages = Int(pageCount)
        pageContr.addTarget(self, action:  #selector(self.pageChanged), for: .valueChanged)
        
        for i in 0..<Int(pageCount) {
            let image = UIImageView(frame: CGRect(x: self.scrolMain.frame.size.width * CGFloat(i), y: 0, width: self.scrolMain.frame.size.width, height: self.scrolMain.frame.size.height))
            image.clipsToBounds = true
            if fake {
                
            } else {
                image.sd_setImage(with: URL(string: images[i].url), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
            }
            image.contentMode = UIViewContentMode.scaleAspectFit
            self.scrolMain.addSubview(image)
        }
    }
    
    
    
    //MARK: UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewWidth: CGFloat = scrollView.frame.size.width
        let pageNumber = floor((scrollView.contentOffset.x - viewWidth / 50) / viewWidth) + 1
        pageContr.currentPage = Int(pageNumber)
    }
    
    //MARK: Page tap action
    @objc func pageChanged() {
        let pageNumber = pageContr.currentPage
        var frame = scrolMain.frame
        frame.origin.x = frame.size.width * CGFloat(pageNumber)
        frame.origin.y = 0
        scrolMain.scrollRectToVisible(frame, animated: true)
    }
    
}
