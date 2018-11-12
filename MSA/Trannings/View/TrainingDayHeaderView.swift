//
//  TrainingDayHeaderView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/22/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import FZAccordionTableView

protocol Toggable {
    mutating func toggle()
}

class TrainingDayHeaderView: FZAccordionTableViewHeaderView {
    
    
    @IBOutlet weak var mainViewLeading: NSLayoutConstraint!
    @IBOutlet weak var mainViewTraling: NSLayoutConstraint!

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var changeDateButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var startTrainingButton: UIButton!
    @IBOutlet weak var sircleTrainingButton: UIButton!
    @IBOutlet weak var openHideExercisesButton: UIButton!
    
    var headerState: HeaderState = .unselected {
        didSet{
            setState(headerState)
        }
    }
    
    enum HeaderState: Toggable {
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
    
    private func setState(_ state: HeaderState) {
        switch state {
        case .unselected:
            openHideExercisesButton.setImage(#imageLiteral(resourceName: "cevron_down_disabled_24px"), for: .normal)
        case .selected:
            openHideExercisesButton.setImage(#imageLiteral(resourceName: "cevron_up_disabled_24px"), for: .normal)
        }
    }
}
