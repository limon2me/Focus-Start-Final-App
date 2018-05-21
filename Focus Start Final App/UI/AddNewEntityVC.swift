//
//  AddNewVC.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 14.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import UIKit

class AddNewEntityVC: UIViewController {

    @IBOutlet weak var myTextField: UITextField!
    
    var text: String? {
        didSet {
            enableSaveButton()
        }
    }
    
    var passBackClosure: ((String) -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let text = self.text, !text.isEmpty {
            self.myTextField.text = text
        } else {
            disableSaveButton()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any)
    {
        self.myTextField.resignFirstResponder()
        if let passBackClosure = self.passBackClosure, let text = self.text {
            passBackClosure(text)
        }
    }
    
    @IBAction func myTextFieldEditingChanged(_ sender: UITextField)
    {
        if let text = sender.text, !text.isEmpty {
            self.text = text
        }
        else {
            disableSaveButton()
        }
    }
    
    func disableSaveButton()
    {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func enableSaveButton()
    {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 29/255,
                                                                    green: 155/255,
                                                                    blue: 246/255,
                                                                    alpha: 1.0)
    }
}
