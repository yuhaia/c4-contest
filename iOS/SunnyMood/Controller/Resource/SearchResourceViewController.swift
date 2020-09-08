//
//  SearchResourceViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/15.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import PolioPager

class SearchResourceViewController: UIViewController, PolioPagerSearchTabDelegate, UITextFieldDelegate  {

    @IBOutlet weak var searchedContentLabel: UILabel!
    
    var searchBar: UIView!
    var searchTextField: UITextField!
    var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField?.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return true}
        self.searchedContentLabel.text = text
        return true
    }
}
