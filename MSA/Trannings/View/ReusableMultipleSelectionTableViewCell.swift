//
//  ReuableMultipleSelectionTableViewCell.swift
//  Trend App
//
//  Created by Dmytro Pasinchuk on 09.05.18.
//  Copyright © 2018 Andrey Solodkyy. All rights reserved.
//

import UIKit

class ReusableMultipleSelectionTableViewCell: UITableViewCell {
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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var radioImage: UIImageView!
    @IBOutlet weak var exerciseImage: UIImageView!
    
    private var imageForUnselectedStage: UIImage?
    private var imageForSelectedStage: UIImage?

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
    
    private func setImage(for selectionClass: CellClass) {
        switch selectionClass {
        case .singleSelection:
            imageForUnselectedStage = #imageLiteral(resourceName: "radioButton")
            imageForSelectedStage = #imageLiteral(resourceName: "checkmark")
        case .multipleSelection:
            imageForUnselectedStage = #imageLiteral(resourceName: "checkbox-empty")
            imageForSelectedStage = #imageLiteral(resourceName: "checkbox-filled")
        }
    }
    
    private func setState(_ state: CellState) {
        switch state {
        case .unselected:
            radioImage.image = imageForUnselectedStage
        case .selected:
            radioImage.image = imageForSelectedStage
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionClass = .multipleSelection
        self.cellState = .unselected
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
