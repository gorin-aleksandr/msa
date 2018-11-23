
//
//  ApproachTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/20/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ApproachTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var weightAndCountsLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var restButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(iteration: Iteration, indexPath: IndexPath) {
        self.numberLabel.text = "#\(indexPath.row+1):"
        self.weightAndCountsLabel.text = "\(iteration.weight) кг х \(iteration.counts) раз"
        var wMin = Int(iteration.workTime/60)
        var rMin = Int(iteration.restTime/60)
        var wSec = Int(iteration.workTime-wMin*60)
        var rSec = Int(iteration.restTime-rMin*60)
        if wMin < 0 {
            wMin = 0
        }
        if wSec < 0 {
            wSec = 0
        }
        if rMin < 0 {
            rMin = 0
        }
        if rSec < 0 {
            rSec = 0
        }
        let wMinStr = wMin<10 ? "0\(wMin)" : "\(wMin)"
        let wSecStr = wSec<10 ? "0\(wSec)" : "\(wSec)"
        let rMinStr = rMin<10 ? "0\(rMin)" : "\(rMin)"
        let rSecStr = rSec<10 ? "0\(rSec)" : "\(rSec)"
        self.workTimeLabel.text = "\(wMinStr):\(wSecStr)"
        self.restTimeLabel.text = "\(rMinStr):\(rSecStr)"
        
        restButton.tag = indexPath.row
    }
    
}
