//
//  CheckOutScreen.swift
//  FRATELLI
//
//  Created by Sakshi on 06/12/24.
//

import UIKit
import CoreLocation

class CheckOutScreen: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var proceedBtn: UIButton?
    var date: String?
    var time: String?
    var address: String?
    var accountId: String = ""
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentAddress: String = "Unknown Location"
    var visitsTable = VisitsTable()
    var visits = [Visit]()
    var customDateFormatter = CustomDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        date = dateFormatter.string(from: currentDate)
        dateFormatter.dateFormat = "HH:mm:ss"
        time = dateFormatter.string(from: currentDate)
        
        proceedBtn?.layer.masksToBounds = true
        proceedBtn?.layer.cornerRadius = 8
        TableVw?.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        // Reverse geocoding to get address (optional)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                self.currentAddress = placemark.name ?? "Unknown Location"
            }
        }
    }
    
//    @IBAction func proceedAction() {
//        guard let currentLocation = currentLocation else {
//            let alert = UIAlertController(
//                title: "Location Unavailable",
//                message: "Unable to get your current location. Please try again later.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
//        
//        let currentLatitude = "\(currentLocation.coordinate.latitude)"
//        let positiveLongitude = currentLocation.coordinate.longitude
//        let currentLongitude = "\(abs(positiveLongitude))"
//        let currentDateTime = CustomDateFormatter.getCurrentDateTime()
//        
//        let checkOutalert = UIAlertController(
//            title: "Confirmation",
//            message: "Are you sure you want to Check-Out?",
//            preferredStyle: .alert
//        )
//        self.present(checkOutalert, animated: true, completion: nil)
//        checkOutalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//        checkOutalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
//            Defaults.isIncompleteVisitName = false
//            Defaults.incompleteVisitName = ""
//            self.visitsTable.updateCheckOutLocation(
//                createdAt: self.customDateFormatter.getFormattedDateForAccount(),
//                actualEnd: self.customDateFormatter.getFormattedDateForAccount(),
//                checkedIn: "0", forVisitId: currentVisitId,
//                checkOutLocation: self.currentAddress,
//                latitude: currentLatitude,
//                longitude: currentLongitude,
//                chcekedOut: true, 
//                isCompleted: "1",
//                fromAppCompleted: "1"
//            ) { success, error in
//                if success {
//                    print("Checkout updated successfully.")
//                    DispatchQueue.main.async {
//                        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
//                        Utility.gotoTabbar()
//                    }
//                } else {
//                    print("Error updating checkout: \(error ?? "Unknown error")")
//                }
//            }
//        }))
//    }
    
    @IBAction func proceedAction() {
        guard let currentLocation = currentLocation else {
            DispatchQueue.main.async { // ✅ Ensure alert is presented on the main thread
                let alert = UIAlertController(
                    title: "Location Unavailable",
                    message: "Unable to get your current location. Please try again later.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        let currentLatitude = "\(currentLocation.coordinate.latitude)"
        let positiveLongitude = currentLocation.coordinate.longitude
        let currentLongitude = "\(abs(positiveLongitude))"
        
        let checkOutalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to Check-Out?",
            preferredStyle: .alert
        )
        
        checkOutalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        checkOutalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Defaults.isIncompleteVisitName = false
            Defaults.incompleteVisitName = ""
            
            self.visitsTable.updateCheckOutLocation(
                createdAt: self.customDateFormatter.getFormattedDateForAccount(),
                actualEnd: self.customDateFormatter.getFormattedDateForAccount(),
                checkedIn: "0",
                forVisitId: currentVisitId,
                checkOutLocation: self.currentAddress,
                latitude: currentLatitude,
                longitude: currentLongitude,
                chcekedOut: true,
                isCompleted: "1",
                fromAppCompleted: "1"
            ) { success, error in
                DispatchQueue.main.async { // ✅ Ensure UI updates run on main thread
                    if success {
                        print("Checkout updated successfully.")
                        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                        Utility.gotoTabbar()
                    } else {
                        print("Error updating checkout: \(error ?? "Unknown error")")
                    }
                }
            }
        }))
        
        DispatchQueue.main.async { // ✅ Ensure alert is presented on the main thread
            self.present(checkOutalert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CheckOutScreen: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CheckOutCell = tableView.dequeueReusableCell(withIdentifier: "CheckOutCell", for: indexPath) as! CheckOutCell
        cell.dateLabel?.text = date
        cell.timeLabel?.text = time
        cell.spentTime?.text = getTimeSpent(checkInDate: Defaults.savedCurrentDate, checkInTime: Defaults.savedCurrentTime)
        return cell
    }
    
    func getTimeSpent(checkInDate: String?, checkInTime: String?) -> String {
        print("Raw checkInDate:", checkInDate as Any)
        print("Raw checkInTime:", checkInTime as Any)

        guard let checkInDate = checkInDate, let checkInTime = checkInTime else {
            return "N/A"
        }

        // Clean special characters (non-breaking/narrow spaces) from time string
        let cleanedTime = checkInTime.replacingOccurrences(of: "\u{202F}", with: " ") // Replace narrow space with normal space
        
        // Combine date + time into one string
        let combinedString = "\(checkInDate) \(cleanedTime)"
        print("Combined string:", combinedString)

        // Parse the combined string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures AM/PM parsing works reliably

        guard let checkInDateTime = dateFormatter.date(from: combinedString) else {
            print("Failed to parse combined: \(combinedString)")
            return "N/A"
        }

        // Calculate time difference
        let currentDate = Date()
        let timeDifference = currentDate.timeIntervalSince(checkInDateTime)

        let secondsInOneDay: TimeInterval = 24 * 60 * 60
        let secondsInOneHour: TimeInterval = 60 * 60

        if timeDifference >= secondsInOneDay {
            let days = Int(timeDifference / secondsInOneDay)
            return "\(days) Days at the Outlet."
        } else {
            let hours = Int(timeDifference / secondsInOneHour)
            let minutes = Int((timeDifference.truncatingRemainder(dividingBy: secondsInOneHour)) / 60)
            let seconds = Int(timeDifference.truncatingRemainder(dividingBy: 60)) // ✅ ← Fixed here!
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
}

class CheckOutCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var spentTime: UILabel?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        vw?.dropShadow()
    }
}
