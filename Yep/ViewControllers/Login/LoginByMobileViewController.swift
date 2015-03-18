//
//  LoginByMobileViewController.swift
//  Yep
//
//  Created by NIX on 15/3/17.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

class LoginByMobileViewController: UIViewController {

    @IBOutlet weak var pickMobileNumberPromptLabel: UILabel!

    @IBOutlet weak var areaCodeTextField: UnderLineTextField!
    @IBOutlet weak var mobileNumberTextField: UnderLineTextField!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        areaCodeTextField.delegate = self
        areaCodeTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)

        mobileNumberTextField.delegate = self
        mobileNumberTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        nextButton.enabled = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        mobileNumberTextField.becomeFirstResponder()
    }

    // MARK: Actions

    func textFieldDidChange(textField: UITextField) {

        nextButton.enabled = !areaCodeTextField.text.isEmpty && !mobileNumberTextField.text.isEmpty
    }

    @IBAction func back(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }


    @IBAction func next(sender: UIButton) {
        tryShowLoginVerifyMobile()
    }

    private func tryShowLoginVerifyMobile() {
        
        view.endEditing(true)

        let mobile = mobileNumberTextField.text
        let areaCode = areaCodeTextField.text

        sendVerifyCode(ofMobile: mobile, withAreaCode: areaCode, failureHandler: { (resource, reason, data) in
            defaultFailureHandler(forResource: resource, withFailureReason: reason, data)

            if let errorMessage = errorMessageInData(data) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    YepAlert.alertSorry(message: errorMessage, inViewController: self, withDismissAction: { () -> Void in
                        mobileNumberTextField.becomeFirstResponder()
                    })
                })
            }
            
        }, completion: { success in
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showLoginVerifyMobile()
                })

            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    YepAlert.alertSorry(message: NSLocalizedString("Failed to send verification code", comment: ""), inViewController: self, withDismissAction: { () -> Void in
                        mobileNumberTextField.becomeFirstResponder()
                    })
                })
            }
        })
    }

    func showLoginVerifyMobile() {
        let mobile = mobileNumberTextField.text
        let areaCode = areaCodeTextField.text

        self.performSegueWithIdentifier("showLoginVerifyMobile", sender: ["mobile" : mobile, "areaCode": areaCode])
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLoginVerifyMobile" {

            if let info = sender as? [String: String] {
                let vc = segue.destinationViewController as! LoginVerifyMobileViewController

                vc.mobile = info["mobile"]
                vc.areaCode = info["areaCode"]
            }
        }
    }

}

extension LoginByMobileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !textField.text.isEmpty {
            tryShowLoginVerifyMobile()
        }
        
        return true
    }
}