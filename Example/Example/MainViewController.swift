//
//  ViewController.swift
//  Example
//
//  Created by Vytautas Galaunia on 14/11/2016.
//  Copyright © 2016 Vytautas Galaunia. All rights reserved.
//

import UIKit


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!

    @IBOutlet var trackingButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateButtonTitle()
    }

    @IBAction func toggleDetection() {
        VLTManager.setEnabled(!VLTManager.isEnabled())
        VLTManager.setDetectionEnabled(VLTManager.isEnabled(), handler: { (result) in
            print("Received result: \(result.toDictionary())")
        })
        updateButtonTitle()
    }

    func updateButtonTitle() {
        let trackingTitle = VLTManager.isEnabled() ? "Stop" : "Start";
        trackingButton.setTitle(trackingTitle, for: .normal)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellIdentifier";
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell!
    }

}

