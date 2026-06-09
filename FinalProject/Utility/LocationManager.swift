import CoreLocation
import Observation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    nonisolated(unsafe) private let clManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    var failed = false

    override init() {
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func request() {
        failed = false
        let status = clManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            clManager.requestLocation()
        case .notDetermined:
            clManager.requestWhenInUseAuthorization()
        default:
            failed = true
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            failed = true
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        failed = true
    }
}
