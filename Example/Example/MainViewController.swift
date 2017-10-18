//
//  ViewController.swift
//  Example
//
//  Created by Vytautas Galaunia on 14/11/2016.
//  Copyright © 2016 Vytautas Galaunia. All rights reserved.
//

import UIKit


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var trackingButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    var totalLocationsReceived: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateButtonTitle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Labeling",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(openLabeling))
    }

    @IBAction func toggleDetection() {
        VLTManager.setEnabled(!VLTManager.isEnabled())
        VLTManager.setTrackingEnabled(true)
        VLTManager.setTrackingDataLimit(100000)
        VLTManager.setDetectionEnabled(VLTManager.isEnabled(), handler: { (result) in
            print("Received result: \(result.toDictionary())")
        })
        updateButtonTitle()
        
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        } else {
            startLocationUpdates()
        }
        locationManager.requestAlwaysAuthorization()
    }

    func startLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func openLabeling() {
        if VLTManager.isEnabled() {
            let vc = LabelingViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Tracking must be enabled", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            }))
            present(alert, animated: true, completion: nil)
        }
    }

    func updateButtonTitle() {
        let trackingTitle = VLTManager.isEnabled() ? "Stop" : "Start";
        trackingButton.setTitle(trackingTitle, for: .normal)
    }

    func updateInfoLabel() {
        let locationsText = "Locations count: \(totalLocationsReceived)"
        let dataText = "tracking data limit reached: \(VLTManager.isTrackingDataLimitReached())"
        infoLabel.text = locationsText + ", " + dataText
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellIdentifier";
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell!
    }

    //MARK: locations
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocationUpdates()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        VLTGPS.locationManager(manager, didUpdate: locations)
        totalLocationsReceived += 1
        updateInfoLabel()
    }
}

