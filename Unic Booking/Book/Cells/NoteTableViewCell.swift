//
//  NoteTableViewCell.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet var executionLabel: UILabel!
    @IBOutlet var noteView: UITextView!
    
    var step: Execution.Step? {
        didSet {
            self.computeStep()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.noteView.delegate = self
        self.noteView.backgroundColor = UIConstants.Color.GRAY_WAITING_BACKGROUND
        self.noteView.textColor = UIConstants.Color.GRAY_TEXT
    }
    
    func computeStep() {
        if let step = self.step {
            self.executionLabel.text = "During \(step.title)"
            self.noteView.text = step.note ?? "Enter note..."
        }
    }
    
    // Mark: - Text View Delegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.step?.note = textView.text
        print("Note : \(self.step) - \(textView.text)")
    }
}
