//
//  ParticipantIDRegistrationViewController.swift
//  PsorcastValidation
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit
import ResearchUI
import Research
import BridgeSDK
import BridgeApp

class ParticipantIDRegistrationStep : RSDUIStepObject, RSDFormUIStep, RSDStepViewControllerVendor {
    
    open func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return ParticipantIDRegistrationViewController(step: self, parent: parent)
    }
    
    let inputFields: [RSDInputField] = {
        let prompt = NSLocalizedString("participant ID", comment: "Localized string for the participant ID prompt")
        let inputField = RSDInputFieldObject(identifier: "participantID", dataType: .base(.string), uiHint: .textfield, prompt: prompt)
        inputField.isOptional = false
        return [inputField]
    }()
    
    required init(identifier: String, type: RSDStepType?) {
        super.init(identifier: identifier, type: type)
        commonInit()
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        commonInit()
    }
    
    private func commonInit() {
        if self.text == nil && self.title == nil {
            self.text = NSLocalizedString("Enter your participant ID.", comment: "Default text for an participant ID registration step.")
        }
    }
}

class ParticipantIDRegistrationViewController: RSDTableStepViewController {

    func participantID() -> String? {
        let participantIDResultIdentifier = "participantID"
        guard let taskResult = self.stepViewModel?.taskResult,
            let participantID = taskResult.findAnswerResult(with: participantIDResultIdentifier)?.value as? String
            else {
                return nil
        }
        return participantID
    }
    
    override func goForward() {
        guard validateAndSave()
            else {
                return
        }
        
        guard let participantID = self.participantID(), !participantID.isEmpty else { return }
        
        // TODO: mdephillips 7/19/19 check bridge and see if participant id is already taken
        // For now, just save it locally
        let defaults = UserDefaults.standard
        defaults.set(participantID, forKey: "participantID")
        
        super.goForward()
    }
}
