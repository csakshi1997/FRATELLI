


import UIKit
import CoreLocation
import Network

func isLocationMocked(_ location: CLLocation) -> Bool {
#if targetEnvironment(simulator)
    return true // Always true in a simulator
#else
    return location.horizontalAccuracy < 0
#endif
}

func addShadow(to view: UIView) {
    view.layer.shadowColor = UIColor(red: 213.0 / 255.0, green: 214.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0).cgColor
    view.layer.shadowOpacity = 0.5
    view.layer.shadowOffset = CGSize(width: -3, height: 3)
    view.layer.shadowRadius = 4
    view.layer.masksToBounds = false
}

class HomeView: UIViewController, CLLocationManagerDelegate, TodayVisitCellDelegate {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet weak var progBar: UIProgressView?
    @IBOutlet var startDayBtn: UIButton?
    @IBOutlet var headerVw: UIView?
    @IBOutlet var noOfCheckIn: UILabel?
    @IBOutlet var totalNoOf: UILabel?
    @IBOutlet var welcomBackLbl: UILabel?
    @IBOutlet var noDataVw: UIView?
    var visitsTable = VisitsTable()
    var visits = [Visit]()
    var outlet = [Outlet]()
    var outletTable = OutletsTable()
    var selectedCells = 0
    var locationManager = CLLocationManager()
    var currentAddress: String = ""
    var isCheckedIn: Bool = false
    var syncDownOperations = SyncDownOperations()
    var isStart: Bool = false
    var totalComplete = 0
    var isSyncCount = 0
    var isCheckInCount = 0
    var fromAppCompltedCount = 0
    var visit: Visit?
    var customDateFormatter = CustomDateFormatter()
    var contacts = [Contact]()
    var localIds = [Int]()
    var contactsTable = ContactsTable()
    var appVersionOperation = AppVersionOperation()
    var incompleteVisitName: String = ""
    private var lastSavedLocation: CLLocation?
    private var locationTable = LocationTable()
    private var timer: Timer?
    var locationSyncManager = LocationSyncManager()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    var planDateInCaseAdhoc: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        noDataVw?.isHidden = true
        contacts = contactsTable.getContactsWhereIsWorkingOutletsOne()
        for cont in contacts {
            localIds.append(cont.localId ?? Int())
        }
        if !localIds.isEmpty {
            contactsTable.updateWorkingWithOutleForMultipleIds(localIds: localIds)
        }
        compareAppVersions()
        appVersionOperation.getInternals { error, response, statusCode in
            if let error = error {
                print("❌ Error: \(error)")
                return
            }
            
            guard let response = response,
                  let records = response["records"] as? [[String: Any]],
                  let userInfo = records.first else {
                print("❌ Failed to parse records.")
                return
            }
            
            Tracking_Interval_Sec__c = userInfo["Tracking_Interval_Sec__c"] as? Int ?? 0
            Tracking_Interval_Sec__c = userInfo["Location_Proximity__c"] as? Int ?? 10
            
            print("📌 Tracking Interval: \(Tracking_Interval_Sec__c)")
            print("📌 Location Proximity: \(Tracking_Interval_Sec__c)")
        }
    }
    
    
    
    func requestLocationPermission() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func getFormattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var mockLocationValue = Int()
        guard let newLocation = locations.last else { return }

        // Ensure accuracy is within an acceptable range
        guard newLocation.horizontalAccuracy > 0, newLocation.horizontalAccuracy < 50 else {
            print("🚫 Unreliable location accuracy: \(newLocation.horizontalAccuracy)")
            return
        }

        let isMockLocation = newLocation.horizontalAccuracy > 20
        if isMockLocation {
            mockLocationValue = 1
        } else {
            mockLocationValue = 0
        }
        // **Ensure the first location is always saved**
        
        // **Check if user has moved at least 80 meters**
        print(lastSavedLocation)
        if let lastLocation = lastSavedLocation {
            let distance = lastLocation.distance(from: newLocation)
            print("📏 Distance from last saved location: \(distance) meters")

            if distance < Double(Location_Proximity__c){
                print("🚫 User has not moved significantly (\(distance)m). Skipping location save.")
                return
            }
        }
        
        if lastSavedLocation == nil {
            print("📍 First location update received. Saving immediately.")
            lastSavedLocation = newLocation
            DispatchQueue.global(qos: .background).async {
                if Defaults.isTrackingStart ?? false {
                    self.saveLocationToDatabase(newLocation, isMockLocation: mockLocationValue, lastLocation: nil)
                }
            }
            return
        }

        // **Update lastSavedLocation and save the new location**
        lastSavedLocation = newLocation
        print("✅ User moved \(lastSavedLocation?.distance(from: newLocation) ?? 0)m, saving location.")

        DispatchQueue.global(qos: .background).async {
            if Defaults.isTrackingStart ?? false {
                self.saveLocationToDatabase(newLocation, isMockLocation: mockLocationValue, lastLocation: nil)
            }
        }
    }
    func saveLocationToDatabase(_ location: CLLocation, isMockLocation: Int, lastLocation: CLLocation?) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        let deviceModel = UIDevice.current.model
        let deviceManufacturer = "Apple"
        
        // Check if distance is 80m before saving
//        if let lastLoc = lastLocation, location.distance(from: lastLoc) < Location_Proximity__c {
//            print("⚠ Distance < 80m. Skipping save.")
//            return
//        }
        
        if let lastLoc = lastLocation, location.distance(from: lastLoc) < Double(Location_Proximity__c) {
            print("⚠ Distance < \(Location_Proximity__c)m. Skipping save.")
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            var address = "Unknown"
            if let placemark = placemarks?.first {
                address = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            }
            
            let locationModel = LocationModel(
                id: nil,
                isOfflineRecord: true,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                address: address,
                isMockLocation: isMockLocation,
                dateTime: CustomDateFormatter.getCurrentDateTime(),
                batteryPercentage: batteryLevel,
                deviceModel: deviceModel,
                deviceManufacturer: deviceManufacturer
            )
            print("💾 Saving location to DB...")
            self.locationTable.saveLocation(location: locationModel) { success, _ in
                if success {
                    print("✅ Location saved. Checking internet for sync...")
                    //                    if self.isInternetAvailable() {
                    //                        DispatchQueue.main.async {
                    //                            self.locationSyncManager.syncOfflineLocationsToServer()
                    //                        }
                    //
                    //                    }
                    
                    if self.isInternetAvailable() {
                        print("🌐 Internet available. Attempting to sync...")
                        DispatchQueue.main.async {
                            print("🔄 Calling syncOfflineLocationsToServer()...")
                            self.locationSyncManager.syncOfflineLocationsToServer()
                        }
                    } else {
                        print("🚫 No internet detected. Sync skipped.")
                    }
                }
            }
        }
    }
    
    private func isInternetAvailable() -> Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    func compareAppVersions() {
        guard let currentVersion = appVersionOperation.getCurrentAppVersion() else {
            print("Unable to retrieve current app version.")
            return
        }
        print("Current Installed Version: \(currentVersion)")
        
        appVersionOperation.checkAppVersionFromAppStore(appID: applicationID) { (appStoreVersion, error) in
            if let error = error {
                print("Error fetching App Store version: \(error)")
                return
            }
            guard let appStoreVersion = appStoreVersion else {
                print("App Store version not found.")
                return
            }
            print("App Store Version: \(appStoreVersion)")
            
            if let comparison = self.appVersionOperation.compareVersions(version1: currentVersion, version2: appStoreVersion) {
                print("Comparison Result: \(comparison.rawValue)")
                if comparison.rawValue < 0 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "New Version Available",
                                                                message: "A newer version of the app is available. Please update to continue using the latest features.",
                                                                preferredStyle: .alert)
                        
                        let updateAction = UIAlertAction(title: "Update Now", style: .default) { _ in
                            if let url = URL(string: "https://apps.apple.com/app/id\(applicationID)") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        alertController.addAction(updateAction)
                        DispatchQueue.main.async {
                            if let topController = UIApplication.shared.keyWindow?.rootViewController {
                                topController.present(alertController, animated: true)
                            }
                        }
                    }
                } else {
                    print("Your app is up to date!")
                }
            } else {
                print("Version comparison failed.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestLocationPermission()
        addButtonBorder()
        visits = visitsTable.fetchTodaysVisits()
        noOfCheckIn?.text = "\(visits.filter { Int($0.isCompleted ?? "") == 1 }.count)"
        let syncCount = "\(visits.filter { Int($0.isSync ?? "") == 0}.count)"
        isSyncCount = Int(syncCount) ?? 0
        let fromAppComplete = "\(visits.filter { Int($0.fromAppCompleted ?? "") == 1}.count)"
        fromAppCompltedCount = Int(fromAppComplete) ?? 0
        let totalCount = noOfCheckIn?.text
        totalComplete = Int(totalCount ?? "0") ?? 0
        let chcekInCount = "\(visits.filter { Int($0.checkedIn) == 1}.count)"
        isCheckInCount = Int(chcekInCount) ?? 0
        outlet = outletTable.getOutletsWithDetails()
        totalNoOf?.text = "\(outlet.count)"
        TableVw?.reloadData()
        addShadow(to: headerVw ?? UIView())
        if Defaults.isStartDay ?? false {
            TableVw?.reloadData()
            welcomBackLbl?.text = ""
            startDayBtn?.setTitle("End Day", for: .normal)
        }
        progressBar()
    }
    
    
    
    func getAllVisitIds() -> [String] {
        return visits.compactMap { $0.accountId }
    }
    
    func setupInitialUI() {
        TableVw?.showsVerticalScrollIndicator = false
        TableVw?.showsHorizontalScrollIndicator = false
        headerVw?.layer.cornerRadius = 10.0
        headerVw?.layer.masksToBounds = true
        progBar?.layer.cornerRadius = 20
        progBar?.trackTintColor = UIColor(red: 220/255, green: 217/255, blue: 215/255, alpha: 255)
        progBar?.progressTintColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        progBar?.progress = 0.0
    }
    
    func progressBar() {
        guard let completedText = noOfCheckIn?.text,
              let totalText = totalNoOf?.text,
              let completed = Float(completedText),
              let total = Float(totalText),
              total > 0 else {
            return
        }
        let progress = completed / total
        progBar?.setProgress(progress, animated: true)
    }
    
    func addButtonBorder() {
        startDayBtn?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        startDayBtn?.layer.borderWidth = 1
        startDayBtn?.layer.cornerRadius = 16.0
        startDayBtn?.layer.masksToBounds = true
    }
    
    @IBAction func startDayAction() {
        self.view.endEditing(true)
        if startDayBtn?.titleLabel?.text == "Start Day" {
            startDayBtn?.setTitle("End Day", for: .normal)
            welcomBackLbl?.text = ""
            Defaults.isStartDay = true
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.distanceFilter = Double(Tracking_Interval_Sec__c)
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.pausesLocationUpdatesAutomatically = false
                locationManager.requestAlwaysAuthorization()
                appDelegate.startLocationTracking()
                Defaults.isTrackingStart = true
            }
        } else if startDayBtn?.titleLabel?.text == "End Day" {
            if (Defaults.isSyncUpComplete ?? false) && (Defaults.isIncompleteVisitName ?? false) {
                let checkINOutalert = UIAlertController(
                    title: "Info",
                    message: "Hey, You have Visit \(Defaults.incompleteVisitName ?? "") is in-progress, please complete this visit first after that you can proceed further.",
                    preferredStyle: .alert
                )
                checkINOutalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(checkINOutalert, animated: true, completion: nil)
                return
            }
            if !(fromAppCompltedCount > 0) {
                let checkINOutalert = UIAlertController(
                    title: "Info",
                    message: "Hey, You have not Completed your daily target yet, Please complete at least one visit to end this day.",
                    preferredStyle: .alert
                )
                checkINOutalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(checkINOutalert, animated: true, completion: nil)
                return
            } else if (isSyncCount > 0) && (fromAppCompltedCount > 0) {
                let checkInalert = UIAlertController(
                    title: "End Day?",
                    message: "Hey, You have not completed your daily target yet, Are you sure, you want to end this day?",
                    preferredStyle: .alert
                )
                self.present(checkInalert, animated: true, completion: nil)
                checkInalert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { _ in
                    print("Cancel tapped")
                }))
                checkInalert.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "SyncInVC") as? SyncInVC {
                        self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
                    }
                }))
            }
        }
        if visits.isEmpty {
            noDataVw?.isHidden = false
        } else {
            TableVw?.reloadData()
        }
    }
}

extension HomeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Defaults.isStartDay ?? false ? visits.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodayVisitCell = tableView.dequeueReusableCell(withIdentifier: "TodayVisitCell", for: indexPath) as! TodayVisitCell
        if !visits.isEmpty {
            let visitsData = visits[indexPath.row]
            cell.upprlBl?.text = visitsData.name
            cell.channelLbl?.text = visitsData.channel
            cell.segmentationLbl?.text = visitsData.accountReference?.classification
            cell.OmniChannelLbl?.text = visitsData.accountReference?.subChannel
            if Int(visitsData.isCompleted ?? "") == 1 || visitsData.status == "Completed" {
                cell.checkInBtn?.setTitle("Completed", for: .normal)
                cell.checkInBtn?.isEnabled = false
                cell.radioBtn?.setImage(UIImage(named: "done"), for: .normal)
            } else {
                cell.checkInBtn?.setTitle("Check In", for: .normal)
                cell.checkInBtn?.isEnabled = true
                cell.radioBtn?.setImage(UIImage(named: ""), for: .normal)
            }
        }
        cell.delegate = self
        return cell
    }
    
    func didTapCheckInButton(in cell: TodayVisitCell) {
        guard let indexPath = TableVw?.indexPath(for: cell) else { return }
        let visit = visits[indexPath.row]
        let checkedInVisits = visitsTable.fetchCheckedInVisits()
        if checkedInVisits.count > 0 {
            if let accId = checkedInVisits.first {
                print(accId.name)
                Defaults.incompleteVisitName = accId.name
                if accId.accountId != visit.accountId {
                    let checkINOutalert = UIAlertController(
                        title: "Found incomplete",
                        message: "Visit \(accId.name) is in-progress, please complete this visit before Check-In to another one.",
                        preferredStyle: .alert
                    )
                    checkINOutalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(checkINOutalert, animated: true, completion: nil)
                    return
                } else {
                    performCheckIn(for: visit)
                }
            }
        } else {
            performCheckIn(for: visit)
        }
    }
    
    func didLocationBtntapped(in cell: TodayVisitCell) {
        guard let indexPath = TableVw?.indexPath(for: cell) else { return }
        let visit = visits[indexPath.row]
        if (visit.checkedInLocationLatitude == "") && (visit.checkedInLocationLongitude == "") {
            let locationAlert = UIAlertController(
                title: "Oops",
                message: "Outlet lat long not found",
                preferredStyle: .alert
            )
            locationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(locationAlert, animated: true, completion: nil)
            return
        } else {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            if let locationVC = storyboard.instantiateViewController(withIdentifier: "GetLocationVC") as? GetLocationVC {
                locationVC.visit = visit
                navigationController?.pushViewController(locationVC, animated: true)
            }
        }
    }
        
    private func performCheckIn(for visit: Visit) {
        guard let accountId = visit.accountId else {
            print("Account ID is missing.")
            return
        }
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services are disabled.")
            return
        }
        
        if CLLocationManager.authorizationStatus() == .denied {
            showLocationDeniedAlert()
            return
        }
        
        locationManager.startMonitoringSignificantLocationChanges()
        guard let currentLocation = locationManager.location else {
            print("Unable to retrieve current location.")
            return
        }
        
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        
        if visit.checkedIn != 1 {
            let checkInalert = UIAlertController(
                title: "Confirmation",
                message: "Are you sure you want to Check-In?",
                preferredStyle: .alert
            )
            self.present(checkInalert, animated: true, completion: nil)
            
            checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
                print("Cancel tapped")
            }))
            
            checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.fetchAddress(from: latitude, longitude: longitude) { address in
                    DispatchQueue.main.async {
                        let checkInAddress = address ?? "Unknown Address"
//                        let dateFormatter = DateFormatter()
//                        dateFormatter.dateStyle = .medium
//                        Defaults.savedCurrentDate = dateFormatter.string(from: Date())
//                        print(Defaults.savedCurrentTime)
//                        Defaults.isIncompleteVisitName = true
//                        print(Defaults.isIncompleteVisitName)
//                        let timeFormatter = DateFormatter()
//                        timeFormatter.timeStyle = .medium
//                        Defaults.savedCurrentTime = timeFormatter.string(from: Date())
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        Defaults.savedCurrentDate = dateFormatter.string(from: Date())

                        let timeFormatter = DateFormatter()
                        timeFormatter.timeStyle = .medium
                        Defaults.savedCurrentTime = timeFormatter.string(from: Date())

                        print(currentVisitId)
                        self.planDateInCaseAdhoc = self.customDateFormatter.getDatePlanVisitInCaseOfADHOC(from: Date())
                        self.visitsTable.updateCheckInLocation(
                            actualStart: self.customDateFormatter.getFormattedDateForAccount(),
                            forVisitId: accountId,
                            isSync: "0",
                            createdAt: self.customDateFormatter.getFormattedDateForAccount(),
                            checkInLocation: checkInAddress,
                            latitude: "\(latitude)",
                            longitude: "\(longitude)",
                            checkedIn: true,
                            externalId: "\(accountId)\(CustomDateFormatter.getCurrentDateTime())"
                            
                        ) { success, error in
                            if success {
                                print(Defaults.savedCurrentTime)
                                self.navigateToCheckInScreen(
                                    date: Defaults.savedCurrentDate ?? "",
                                    time: Defaults.savedCurrentTime ?? "",
                                    address: checkInAddress, 
                                    accountId: accountId,
                                    currentSelectedIdd: visit.id ?? "",
                                    visitPlanDated: visit.visitPlanDate.isEmpty ? self.planDateInCaseAdhoc : visit.visitPlanDate
                                )
                                print("Check-in location updated successfully.")
                            } else {
                                print("Failed to update check-in location: \(error ?? "Unknown error")")
                            }
                        }
                    }
                }
            }))
        } else {
            self.planDateInCaseAdhoc = self.customDateFormatter.getDatePlanVisitInCaseOfADHOC(from: Date())
            fetchAddress(from: latitude, longitude: longitude) { address in
                DispatchQueue.main.async {
                    print(Defaults.savedCurrentTime)
                    self.navigateToCheckInScreen(
                        date: Defaults.savedCurrentDate ?? "",
                        time: Defaults.savedCurrentTime ?? "",
                        address: address ?? "Unknown Address",
                        accountId: accountId,
                        currentSelectedIdd: visit.id ?? "",
                        visitPlanDated: visit.visitPlanDate.isEmpty ? self.planDateInCaseAdhoc : visit.visitPlanDate
                    )
                }
            }
        }
    }
    
    func checkLocationAuthorization() {
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                print("Location access is restricted or denied.")
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            @unknown default:
                break
            }
        } else {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 14.0, *) {
            switch status {
            case .authorizedAlways:
                print("✅ Location permission granted: Always")
                locationManager.startUpdatingLocation()
            case .authorizedWhenInUse:
                print("⚠ Location permission granted: When in use. Requesting Always access...")
                locationManager.requestAlwaysAuthorization()
            case .denied, .restricted:
                print("❌ Location access denied or restricted.")
            case .notDetermined:
                print("❓ Location permission not determined yet.")
            @unknown default:
                break
            }
        } else {
            // For iOS 13 and earlier, use the old method
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways:
                print("✅ Location permission granted: Always")
                locationManager.startUpdatingLocation()
            case .authorizedWhenInUse:
                print("⚠ Location permission granted: When in use. Requesting Always access...")
                locationManager.requestAlwaysAuthorization()
            case .denied, .restricted:
                print("❌ Location access denied or restricted.")
            case .notDetermined:
                print("❓ Location permission not determined yet.")
            @unknown default:
                break
            }
        }
    }
    
    func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Access Denied",
            message: "Please enable location access in Settings to proceed with Check-In.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchAddress(from latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        guard latitude != 0.0, longitude != 0.0 else {
            print("Invalid latitude or longitude.")
            completion(nil)
            return
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocode error: \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.fetchAddress(from: latitude, longitude: longitude, completion: completion)
                }
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found.")
                completion(nil)
                return
            }
            
            var addressString = ""
            if let name = placemark.name { addressString += name + ", " }
            if let locality = placemark.locality { addressString += locality + ", " }
            if let administrativeArea = placemark.administrativeArea { addressString += administrativeArea + ", " }
            if let country = placemark.country { addressString += country }
            
            print("Fetched Address: \(addressString)")
            completion(addressString.isEmpty ? nil : addressString)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    func navigateToCheckInScreen(date: String, time: String, address: String, accountId: String, currentSelectedIdd: String, visitPlanDated: String) {
        print( accountId)
        print("\(accountId)\(CustomDateFormatter.getCurrentDateTime())")
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let checkInScreen = storyboard.instantiateViewController(withIdentifier: "CheckInScreen") as? CheckInScreen {
            checkInScreen.date = date
            checkInScreen.time = time
            checkInScreen.address = address
            checkInScreen.accountId = accountId
            chcekintime = time
            chcekInDate = date
            currentVisitId = accountId
            print(currentVisitId)
            externalID = "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())"
            Defaults.isSyncUpComplete = false
            currentSelectedVisitId = currentSelectedIdd
            visitPlanDate = visitPlanDated
            navigationController?.pushViewController(checkInScreen, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCells = indexPath.row
        TableVw?.reloadData()
    }
}

struct VisitWithOutlet {
    let visit: Visit
    let outletData: Outlet
}

