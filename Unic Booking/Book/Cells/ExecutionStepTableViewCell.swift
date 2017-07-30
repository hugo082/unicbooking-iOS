//
//  ExecutionStepTableViewCell.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 20/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class ExecutionStepTableViewCell: UITableViewCell {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    var step: Execution.Step?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func computeStep(with stepIndex: Int, currentStep: Int) {
        guard let step = self.step else { return }
        self.titleLabel.text = step.title
        self.iconView.image = step.icon?.withRenderingMode(.alwaysTemplate)
        if (stepIndex < currentStep) {
            self.iconView?.backgroundColor = UIConstants.Color.GREEN_SUCCESS_BACKGROUND
            self.titleLabel.textColor = UIConstants.Color.GRAY_PLACEHOLDER
            self.iconView.tintColor = .white
        } else if currentStep == stepIndex {
            self.iconView?.backgroundColor = UIConstants.Color.BLUE_CURRENT_BACKGROUND
            self.titleLabel.textColor = UIConstants.Color.BLUE_CURRENT_BACKGROUND
            self.iconView.tintColor = .white
        } else {
            self.iconView?.backgroundColor = UIConstants.Color.GRAY_WAITING_BACKGROUND
            self.titleLabel.textColor = UIConstants.Color.GRAY_TEXT
            self.iconView.tintColor = .black
        }
    }
    
    func finish() {
        self.iconView?.backgroundColor = UIConstants.Color.GREEN_SUCCESS_BACKGROUND
        self.titleLabel.textColor = UIConstants.Color.GRAY_PLACEHOLDER
    }

}
