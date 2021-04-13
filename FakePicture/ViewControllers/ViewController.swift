//
//  ViewController.swift
//  FakePicture
//
//  Created by maxwell on 11/04/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupElements()
    }
    
    func setupElements(){
        Utilities.styleFilledButton(registerButton)
        Utilities.styleFilledButton(loginButton)
    }


}

