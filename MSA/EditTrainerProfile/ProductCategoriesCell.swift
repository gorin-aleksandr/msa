//
//  ProductCategoriesCell.swift
//  m2m Admin
//
//  Created by Nik on 7/19/18.
//  Copyright © 2018 m2m. All rights reserved.
//
import UIKit
import TagListView

class ProductCategoriesCell: UITableViewCell,TagListViewDelegate {
    
    static let identifier = "ProductCategoriesCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagList: TagListView!
    var addTag: ((String,Bool) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagList.textFont = UIFont(name: "Rubik-Regular", size: 16)!
        tagList.alignment = .left // possible values
        tagList.delegate = self
        
//        titleLabel.textColor = UIColor.secondaryTextDark()
//        titleLabel.font = UIFont.systemFont(ofSize: 14 * screenCoef(), weight: .medium)
        self.sizeToFit()
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        addTag?(title,tagView.isSelected)
    }
    
    func tagInitHighlight(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(tagView.tag), \(sender) TAG = \(index)")
        tagView.isSelected = !tagView.isSelected
    }
    
    
    
}
