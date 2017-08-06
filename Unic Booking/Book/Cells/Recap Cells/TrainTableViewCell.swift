//
//  TrainTableViewCell.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 06/08/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class TrainTableViewCell: UITableViewCell, RecapCell {

    @IBOutlet var iconView: UIImageView!
    @IBOutlet var serviceTypeLabel: UILabel!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var product: Product? {
        didSet {
            updateUI()
        }
    }
    var metadata: Metadata? {
        return self.product?.train
    }
    var trainMetadata: TrainMetadata? {
        return self.metadata as? TrainMetadata
    }
    
    func updateUI() {
        self.iconView.image =  #imageLiteral(resourceName: "icn_train")
        self.serviceTypeLabel.text = self.product?.type.name
        self.codeLabel.text = self.trainMetadata?.code
        self.timeLabel.text = self.trainMetadata?.time?.timeString()
    }

}
