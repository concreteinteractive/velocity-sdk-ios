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

    var results = [VLTMotionDetectResult]()

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
        VLTManager.setDetectionEnabled(VLTManager.isEnabled(), handler: { [weak self] (result) in
            self?.addResult(result: result)
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

    @objc func openLabeling() {
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
        return results.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellIdentifier";
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        let r = results[indexPath.row];
        cell?.textLabel?.text = "Walking: \(r.isWalking) Parked: \(r.isParked) Driving: \(r.isDriving)"
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

    //MARK: resutls

    func addResult(result: VLTMotionDetectResult) {
        results.insert(result, at: 0);
        if (results.count > 100) {
            results.removeLast();
        }
        tableView.reloadData();
    }
}

