//
//  Execution.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class Execution: Model, Updatable, CustomStringConvertible {
    
    class Step: Model {
        
        enum CodingKeys: String, CodingKey  {
            case id, title, note, iconName = "icon_name"
            case finishTime = "finish_time"
        }
        
        let id: Int
        let title: String
        let iconName: String
        var finishTime: Date?
        var note: String?
        
        var icon: UIImage? {
            return UIImage(named: self.iconName)
        }
        var castedNote: String? {
            return self.note != "" ? self.note : nil
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.title = try container.decode(String.self, forKey: .title)
            self.finishTime = try container.decodeIfPresent(Date.self, forKey: .finishTime)
            self.note = try container.decodeIfPresent(String.self, forKey: .note)
            self.iconName = try container.decode(String.self, forKey: .iconName)
        }
    }
    
    enum State: String, Decodable {
        case waiting = "Waiting"
        case progress = "In progress"
        case finished = "Finished"
        case empty = "Empty"
    }
    
    enum CodingKeys: String, CodingKey  {
        case id, state, steps
        case currentStepIndex = "current_step"
    }
    
    let id: Int
    var currentStepIndex: Int?
    var forceCurrentStepIndex: Int {
        return currentStepIndex ?? -1
    }
    var currentStep: Step? {
        guard let index = currentStepIndex, index >= 0 && index < self.steps.count else { return nil }
        return self.steps[index]
    }
    var state: State
    var steps: [Step]
    
    func getStepWithNote() -> [Step] {
        return self.steps.filter() { step in
            return step.note != nil && step.note != ""
        }
    }
    
    func complete(step: Step) -> Bool {
        if (step.id == self.currentStep?.id) {
            self.currentStep?.finishTime = Date()
            return true
        }
        return false
    }
    
    func nextStep() {
        self.currentStepIndex = (self.currentStepIndex ?? -1) + 1
    }
    
    // Mark: - Updatable
    
    func update(from object: Execution) {
        self.currentStepIndex = object.currentStepIndex
        self.state = object.state
        self.steps = object.steps
    }
    
    // Mark: - Decodable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.currentStepIndex = try container.decodeIfPresent(Int.self, forKey: .currentStepIndex)
        self.state = try container.decode(State.self, forKey: .state)
        self.steps = try container.decode([Step].self, forKey: .steps)
    }
    
    // MARK: - Default
    
    var description: String {
        return "Execution(Step:\(self.forceCurrentStepIndex) - counts:\(self.steps.count) - state:\(self.state)"
    }
}
