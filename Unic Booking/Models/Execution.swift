//
//  Execution.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

class Execution: Model {
    
    class Step: Model {
        
        enum CodingKeys: String, CodingKey  {
            case id, title, note
            case finishTime = "finish_time"
        }
        
        let id: Int
        let title: String
        let icon: String
        var finishTime: Date?
        var note: String?
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.title = try container.decode(String.self, forKey: .title)
            self.finishTime = try container.decode(Date.self, forKey: .finishTime)
            self.note = try container.decode(String.self, forKey: .note)
            self.icon = ""
        }
    }
    
    enum CodingKeys: String, CodingKey  {
        case id, state, steps
        case currentStepIndex = "current_step"
    }
    
    let id: Int
    var currentStepIndex: Int
    var currentStep: Step {
        return self.steps[self.currentStepIndex]
    }
    let state: String
    let steps: [Step]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.currentStepIndex = try container.decode(Int.self, forKey: .currentStepIndex)
        self.state = try container.decode(String.self, forKey: .state)
        self.steps = try container.decode([Step].self, forKey: .steps)
    }
    
    func getStepWithNote() -> [Step] {
        var res: [Step] = []
        for (index, step) in self.steps.enumerated() {
            if (index > self.currentStepIndex) {
                return res
            }
            if step.note != nil || index == self.currentStepIndex {
                res.append(step)
            }
        }
        return res;
    }
    
    func complete(step: Step) -> Bool {
        if (step.id == self.currentStep.id) {
            self.currentStep.finishTime = Date()
            self.currentStepIndex += 1
            return true
        }
        return false
    }
}
