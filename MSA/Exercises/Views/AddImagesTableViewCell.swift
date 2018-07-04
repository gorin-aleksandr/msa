//
//  AddImagesTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

protocol ImagesProtocol {
    func deleteImage(at index: Int)
}

class AddImagesTableViewCell: UITableViewCell,UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var lab: UILabel!
    @IBOutlet weak var log: UIImageView!
    @IBOutlet weak var photoCounter: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hieghtOfColView: NSLayoutConstraint!
    
    var images = [Data]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var delegate: ImagesProtocol?
    
    override func awakeFromNib() {

        let nibName = UINib(nibName: "ImageCollectionViewCell", bundle:nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.image.image = UIImage(data: images[indexPath.row])
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func deleteItem(_ sender: UIButton) {
        delegate?.deleteImage(at: sender.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 98, height: 98)
    }
    
    
}
