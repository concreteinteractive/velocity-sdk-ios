//
//  LabelingViewController.swift
//  Example
//
//  Created by Vytautas Galaunia on 18/10/2017.
//  Copyright © 2017 Vytautas Galaunia. All rights reserved.
//

import UIKit

class LabelingViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = "";
    }

    @IBAction func submitLabels() {
        let characterSet = CharacterSet.whitespaces.union(CharacterSet(charactersIn: ","))
        if let tags = textField.text?.components(separatedBy: characterSet).filter({ !$0.isEmpty }), tags.count > 0 {
            print("TAGS: \(tags)")
            spinner.startAnimating()
            VLTManager.labelCurrentMotion(with: tags, completion: { [weak self] (success) in
                self?.spinner.stopAnimating()
            })
            errorLabel.text = "";
        } else {
            errorLabel.text = "No tags were found";
        }
    }

}
