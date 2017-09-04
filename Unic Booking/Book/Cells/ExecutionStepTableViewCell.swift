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
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    
    var step: Execution.Step?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func computeStep(with stepIndex: Int, currentStep: Int, baggages: Int) {
        guard let step = self.step else { return }
        self.titleLabel.text = step.title
        self.iconView.image = step.icon?.withRenderingMode(.alwaysTemplate)
        if (stepIndex < currentStep) { // Finish
            self.iconView?.backgroundColor = UIConstants.Color.GREEN_SUCCESS_BACKGROUND
            self.titleLabel.textColor = UIConstants.Color.GRAY_PLACEHOLDER
            self.iconView.tintColor = .white
            self.timeLabel.text = self.step?.finishTime?.timeString()
        } else {
            if currentStep == stepIndex { // Current
                self.iconView?.backgroundColor = UIConstants.Color.BLUE_CURRENT_BACKGROUND
                self.titleLabel.textColor = UIConstants.Color.BLUE_CURRENT_BACKGROUND
                self.iconView.tintColor = .white
            } else { // Waiting
                self.iconView?.backgroundColor = UIConstants.Color.GRAY_WAITING_BACKGROUND
                self.titleLabel.textColor = UIConstants.Color.GRAY_TEXT
                self.iconView.tintColor = .black
            }
            if self.step?.iconName == "icn_baggage" {
                self.timeLabel.text = "Count \n\(baggages)"
            } else {
                self.timeLabel.isHidden = true
            }
        }
        self.configureAction()
    }
    
    func finish() {
        self.iconView?.backgroundColor = UIConstants.Color.GREEN_SUCCESS_BACKGROUND
        self.titleLabel.textColor = UIConstants.Color.GRAY_PLACEHOLDER
    }
    
    func configureAction() {
        if self.step?.tag == .linkInfo {
            self.actionButton.setTitle("Call", for: .normal)
        } else {
            self.actionButton.isHidden = true
        }
    }
}
