//
//  addWeekDayView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 10/27/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import FZAccordionTableView

class addWeekDayView: TrainingDayHeaderView {

    @IBOutlet weak var bgView: UIView! {didSet{bgView.layer.cornerRadius = 12}}
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labell: UILabel!
    @IBOutlet weak var butt: UIButton!
    
}
