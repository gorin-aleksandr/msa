//
//  ExercisesTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/14/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage

class ExercisesTableViewCell: UITableViewCell {
    
    var imageTapped: (()->())?
    var descriptionTapped: (()->())?

    @IBAction func imageTapped(_ sender: Any) {
        imageTapped?()
    }
    @IBAction func descriptionTapped(_ sender: Any) {
        descriptionTapped?()
    }
    
    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var exerciseImage: UIImageView! {didSet{exerciseImage.layer.cornerRadius = 10}}
    @IBOutlet weak var exercisename: UILabel!
    
    enum CellClass {
        case singleSelection, multipleSelection
    }
    
    enum CellState: Toggable {
        case unselected, selected
        
        mutating func toggle() {
            switch self {
            case .unselected:
                self = .selected
            case .selected:
                self = .unselected
            }
        }
    }
    var selectionClass: CellClass = .multipleSelection {
        didSet {
            setImage(for: selectionClass)
        }
    }
    var cellState: CellState = .unselected {
        didSet{
            setState(cellState)
        }
    }
    private var imageForUnselectedStage: UIImage?
    private var imageForSelectedStage: UIImage?
    
    private func setImage(for selectionClass: CellClass) {
        switch selectionClass {
        case .singleSelection:
            imageForUnselectedStage = UIImage(named: "checkbox-empty")!
            imageForSelectedStage = UIImage(named: "checkbox-filled")!
        case .multipleSelection:
            imageForUnselectedStage = UIImage(named: "checkbox-empty")!
            imageForSelectedStage = UIImage(named: "checkbox-filled")!
        }
    }
    
    private func setState(_ state: CellState) {
        switch state {
        case .unselected:
            checkBoxImage.image = UIImage(named: "checkbox-empty")!
        case .selected:
            checkBoxImage.image = UIImage(named: "checkbox-filled")!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionClass = .multipleSelection
        self.cellState = .unselected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configureCell(with exercise: Exercise) {
        exerciseImage.sd_setImage(with: URL(string: exercise.pictures.first?.url ?? ""), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        exercisename.text = exercise.name
    }
    
}
