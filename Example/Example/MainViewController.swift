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

    @IBAction func toggleTracking() {
        VLTManager.setTrackingEnabled(!VLTManager.isTrackingEnabled());
        updateButtonTitle()
    }

    func updateButtonTitle() {
        let trackingTitle = VLTManager.isTrackingEnabled() ? "Stop Tracking" : "Start Tracking";
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

