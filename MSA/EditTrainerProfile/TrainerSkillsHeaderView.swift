//
//  TrainingDayHeaderView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/22/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import FZAccordionTableView

class TrainerSkillsHeaderView: FZAccordionTableViewHeaderView {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var openHideSkillButton: UIButton!
    
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
            openHideSkillButton.setImage(#imageLiteral(resourceName: "cevron_down_disabled_24px"), for: .normal)
        case .selected:
            openHideSkillButton.setImage(#imageLiteral(resourceName: "cevron_up_disabled_24px"), for: .normal)
        }
    }
}
