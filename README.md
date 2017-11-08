# velocity-sdk-ios

## Setup ##
In your app delegate set unique api token which is assigned to your company

```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    ...
    VLTManager.setApiToken("unique_token_assigned_to_you")
    ...
}```

You can also set custom user id:
```VLTManager.setUserId(NSUUID().uuidString)```

## Motion Detection ##

Enable motions detection and add a completion block to listen for new detections

```
VLTManager.setEnabled(true)
VLTManager.setDetectionEnabled(VLTManager.isEnabled(), handler: { [weak self] (result) in
    if result.isParked {
        print("User has parked")
    }
})
```

### Driving detection ###

If you want to use CoreMotion to detect driving in addition of average speed calculation:

```VLTManager.setMotionActivityTrackingEnabled(true)```

## Tracking ##

It sends all gathered motion data to backend for storing

To enable tracking:
```
VLTManager.setEnabled(true)
VLTManager.setTrackingEnabled(true)
```

### Throttling ###
You can limit the tracking data by:
```VLTManager.setTrackingDataLimit(100000)```

This byte count threshold is used for cellular uploads (wifi upload is not limited) per 1 calendar day.

To check if limit is reached:
```VLTManager.isTrackingDataLimitReached()```

### GPS ###
To send GPS data in your CLLocationManager delegate add:

```
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    VLTGPS.locationManager(manager, didUpdate: locations)
}
```

### Sending Labels ###

You can add label to motion data gathered in buffer and send it backend for storing:

```
let tags = ["park", "some other tag"]

VLTManager.labelCurrentMotion(with: tags)

//or below one if you need a callback

VLTManager.labelCurrentMotion(with: tags) { [weak self] (success) in
    //Labels sent
})
```

### Code formatting
