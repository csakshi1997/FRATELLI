//
//  VisibilityVC.swift
//  FRATELLI
//
//  Created by Sakshi on 05/12/24.
//


import UIKit
import AVFoundation
import Photos
import MaterialComponents.MaterialTextControls_OutlinedTextFields

protocol CheckboxCellDelegate: AnyObject {
    func didToggleCheckbox(at indexPath: IndexPath, isFirst: Bool, isChecked: Bool)
}

protocol ImagePopForVisibilityDelegate: AnyObject {
    func didUpdateImage(image: UIImage, forIndex index: IndexPath)
}

class VisibilityVC: UIViewController, CheckboxCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var nodataVw: UIView?
    @IBOutlet var footerView: UIView?
    @IBOutlet var countLbl: UILabel?
    @IBOutlet var proceedBtn: UIButton?
    @IBOutlet var txtView: UITextView?
    var date: String?
    var time: String?
    var address: String?
    var accountId: String = ""
    var assetModel = [AssetModel]()
    var onAssetsTable = OnAssetsTable()
    var allVisibilityData: [AllVisibilityModel] = []
    var sessionModel = [sessetmodel]()
    var customDateFormatter = CustomDateFormatter()
    var allVisibilityTable = AllVisibilityTable()
    var selectedIndexPath: IndexPath?
    let characterLimit = 212
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    var qCROperation = QCROperation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtView?.delegate = self
        proceedBtn?.layer.masksToBounds = true
        proceedBtn?.layer.cornerRadius = 8
        TableVw?.delegate = self
        TableVw?.dataSource = self
        TableVw?.reloadData()
        txtView?.dropShadow()
        proceedBtn?.layer.cornerRadius = 8.0
        proceedBtn?.layer.masksToBounds = true
        txtView?.placeholder = "Add Remark"
        txtView?.textColor = .darkGray
        txtView?.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 13)
        addTapGestureToDismissKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let textView = txtView?.viewWithTag(101) as? UITextView {
            textView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        assetModel = onAssetsTable.getAssets()
        if assetModel.isEmpty {
            nodataVw?.isHidden = false
            print("assetModel is empty. Please check its initialization.")
        } else {
            initializeSessionModel()
            nodataVw?.isHidden = true
        }
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == txtView {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            textView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = size.height
                }
            }
            let currentCount = textView.text.count
            countLbl?.text = "\(currentCount)"
            if textView.text.isEmpty {
                textView.setPlaceholder("Add Remark")
            } else {
                textView.removePlaceholder()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let updatedTextLength = currentText.count - range.length + text.count
        return updatedTextLength <= 212
    }
    
    func initializeSessionModel() {
        if sessionModel.isEmpty {
            sessionModel = assetModel.map { asset in
                let session = sessetmodel()
                session.asset = asset.Label
                session.isPresent = false
                session.isMaintenance = false
                return session
            }
            TableVw?.reloadData()
        }
    }
    
    func didToggleCheckbox(at indexPath: IndexPath, isFirst: Bool, isChecked: Bool) {
        let session = sessionModel[indexPath.row]
        if isFirst {
            session.isPresent = isChecked
        } else {
            session.isMaintenance = isChecked
        }
        print("Updated \(session.asset ?? ""): isPresent = \(session.isPresent ?? false), isMaintenance = \(session.isMaintenance ?? false)")
    }
    
    private func uploadNextAsset(from assets: [sessetmodel], index: Int) {
        guard index < assets.count else {
            print("✅ All assets uploaded successfully.")
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "AddNewTasksVC") as? AddNewTasksVC {
                self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
            }
            return
        }
        
        let asset = assets[index]
        
        // Ensure image is available
        guard let imageName = asset.image,
              let image = loadImageFromDocuments(imageName: imageName) else {
            print("⚠️ Error: Could not find image for asset \(asset.asset ?? "Unknown")")
            uploadNextAsset(from: assets, index: index + 1) // Move to next asset
            return
        }
        
        // Convert image to Base64
        guard let base64String = convertImageToBase64(image: image) else {
            print("⚠️ Error: Could not convert image \(asset.asset ?? "") to Base64")
            uploadNextAsset(from: assets, index: index + 1) // Move to next asset
            return
        }
        
        // Convert Base64 to Hex (for server transmission)
        guard let hexString = convertBase64ToHex(base64String: base64String) else {
            print("⚠️ Error: Could not convert Base64 to Hex for \(asset.asset ?? "")")
            uploadNextAsset(from: assets, index: index + 1) // Move to next asset
            return
        }
        
        let params: [String: Any] = [
            "Title": "OutletVisibility-\(asset.asset ?? "")-000\(index)",
            "AccountId": currentVisitId,
            "PathOnClient": asset.image ?? "",
            "FileDataHex": hexString
        ]
        print(params)
        qCROperation.executeUploadImage(localId: 0, param: params) { error, response, statusCode in
            if let error = error {
                print("❌ Error uploading \(asset.asset ?? ""): \(error)")
            } else {
//                self.skipTable.updateAssetVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, assetVisibility: "0") { success, error in
//                    if success {
//                        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//                        if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
//                            self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
//                        }
//                    } else {
//                        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//                        if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
//                            self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
//                        }
//                    }
//                }
                SceneDelegate.getSceneDelegate().window?.makeToast(VISIBILITY_CREATED)
            }
            self.uploadNextAsset(from: assets, index: index + 1)
        }
    }
    
    private func loadImageFromDocuments(imageName: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(imageName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func convertImageToBase64(image: UIImage) -> String? {
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300)) // Resize image
        guard let compressedImageData = resizedImage.jpegData(compressionQuality: 0.2) else { return nil } // Compress image
        print("Compressed Image Size: \(Double(compressedImageData.count) / 1024.0) KB") // Debug: Check file size
        return compressedImageData.base64EncodedString()
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = (widthRatio > heightRatio) ?
        CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
        CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func convertBase64ToHex(base64String: String) -> String? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return imageData.map { String(format: "%02x", $0) }.joined()
    }
    

    
    
//    @objc func selectImageButtonTapped(_ sender: UIButton) {
//        let indexPathRow = sender.tag
//        selectedIndexPath = IndexPath(row: indexPathRow, section: 0)
//        
//        func showImagePicker(sourceType: UIImagePickerController.SourceType) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = sourceType
//            
//            if let popoverController = imagePicker.popoverPresentationController {
//                popoverController.sourceView = sender
//                popoverController.sourceRect = sender.bounds
//                popoverController.permittedArrowDirections = .any
//            }
//            
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//        
//        func requestCameraPermission() {
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    if granted {
//                        showImagePicker(sourceType: .camera)
//                    } else {
//                        self.showPermissionAlert(for: "Camera")
//                    }
//                }
//            }
//        }
//        
//        func requestPhotoLibraryPermission() {
//            PHPhotoLibrary.requestAuthorization { status in
//                DispatchQueue.main.async {
//                    switch status {
//                    case .authorized, .limited:
//                        showImagePicker(sourceType: .photoLibrary)
//                    default:
//                        self.showPermissionAlert(for: "Photo Library")
//                    }
//                }
//            }
//        }
//        
//        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
//            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
//            switch cameraStatus {
//            case .authorized:
//                showImagePicker(sourceType: .camera)
//            case .notDetermined:
//                requestCameraPermission()
//            default:
//                self.showPermissionAlert(for: "Camera")
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
//            let photoStatus = PHPhotoLibrary.authorizationStatus()
//            switch photoStatus {
//            case .authorized, .limited:
//                showImagePicker(sourceType: .photoLibrary)
//            case .notDetermined:
//                requestPhotoLibraryPermission()
//            default:
//                self.showPermissionAlert(for: "Photo Library")
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        if let popoverController = alert.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
//            popoverController.permittedArrowDirections = .any
//        }
//        
//        self.present(alert, animated: true, completion: nil)
//    }
    
    @objc func selectImageButtonTapped(_ sender: UIButton) {
        let indexPathRow = sender.tag
        selectedIndexPath = IndexPath(row: indexPathRow, section: 0)
        
        func showImagePicker(sourceType: UIImagePickerController.SourceType) {
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "Unavailable", message: "This source is not available on your device.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
                return
            }

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false

            if let popoverController = imagePicker.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
                popoverController.permittedArrowDirections = .any
            }

            self.present(imagePicker, animated: true)
        }

        func requestCameraPermission() {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showImagePicker(sourceType: .camera)
                    } else {
                        self.showPermissionAlert(for: "Camera")
                    }
                }
            }
        }

        func requestPhotoLibraryPermission() {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        showImagePicker(sourceType: .photoLibrary)
                    default:
                        self.showPermissionAlert(for: "Photo Library")
                    }
                }
            }
        }

        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                let alert = UIAlertController(title: "Camera Unavailable", message: "This device does not support the camera.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }

            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch cameraStatus {
            case .authorized:
                showImagePicker(sourceType: .camera)
            case .notDetermined:
                requestCameraPermission()
            default:
                self.showPermissionAlert(for: "Camera")
            }
        }))

//        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
//            let photoStatus = PHPhotoLibrary.authorizationStatus()
//            switch photoStatus {
//            case .authorized, .limited:
//                showImagePicker(sourceType: .photoLibrary)
////            case .notDetermined:
////                requestPhotoLibraryPermission()
//            default:
//                self.showPermissionAlert(for: "Photo Library")
//            }
//        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }

        self.present(alert, animated: true)
    }

    func showPermissionAlert(for feature: String) {
        let alert = UIAlertController(
            title: "\(feature) Access Denied",
            message: "Please enable access to \(feature) in Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        if let imageData = selectedImage.jpegData(compressionQuality: 0.2) {
            let fileName = UUID().uuidString + ".png"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
            if let indexPath = selectedIndexPath {
                sessionModel[indexPath.row].image = fileName
                TableVw?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func proceedAction() {
        let isAnyImageSelected = sessionModel.contains { $0.image != nil && $0.image != "" }
        if !isAnyImageSelected {
            showAlert()
            return
        }
        
        guard !sessionModel.isEmpty else { return }
        let remarkText = txtView?.text
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var visibilityData: [AllVisibilityModel] = []
            
            for session in self.sessionModel {
                guard let imageName = session.image,
                      let image = self.loadImageFromDocuments(imageName: imageName),
                      let base64String = self.convertImageToBase64(image: image),
                      let hexString = self.convertBase64ToHex(base64String: base64String) else {
                    continue
                }

                let visibilityModel = AllVisibilityModel(
                    LocalId: nil,
                    External_Id__c: externalID,
                    outletId: currentVisitId,
                    assetName: session.asset,
                    addRemark: remarkText,
                    assetItemImg: session.image,
                    isPresent: session.isPresent ?? false ? "1" : "0",
                    isMaintenance: session.isMaintenance ?? false ? "1" : "0",
                    isSync: "0",
                    hexString: hexString,
                    createdAt: customDateFormatter.getFormattedDateForAccount()
                )
                visibilityData.append(visibilityModel)
            }

            allVisibilityTable.saveVisibility(models: visibilityData) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.skipTable.updateAssetVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, assetVisibility: "0") { success, error in
                            if success {
                                SceneDelegate.getSceneDelegate().window?.makeToast(VISIBILITY_CREATED)
                                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
                                    self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
                                }
                            } else {
                                print("Failed to update assetVisibility skip: \(error ?? "Unknown error")")
                            }
                        }
                        
                    } else {
                        SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
                    }
                }
            }
        }
    }
    
    func showAlert() {
        let checkInalert = UIAlertController(
            title: "Alert",
            message: "Please select atleast one image",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
    }
    
    
    func uploadAssetsToServer(assets: [sessetmodel]) {
        guard !assets.isEmpty else {
            print("No assets to upload.")
            return
        }
        uploadNextAsset(from: assets, index: 0)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func skipAction() {
        skipTable.updateAssetVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, assetVisibility: "1") { success, error in
            if success {
                print("assetVisibility skip updated successfully!")
            } else {
                print("Failed to update assetVisibility skip: \(error ?? "Unknown error")")
            }
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
            self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
        }
    }
}

extension VisibilityVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VisibilityCell = tableView.dequeueReusableCell(withIdentifier: "VisibilityCell", for: indexPath) as! VisibilityCell
        let session = sessionModel[indexPath.row]
        cell.headingLbl?.text = session.asset
        cell.indexPath = indexPath
        cell.delegate = self
        cell.parentVC = self
        cell.firstBtn.isSelected = session.isPresent ?? false
        cell.firstBtn.setImage(UIImage(named: session.isPresent == true ? "checkBox" : "uncheck"), for: .normal)
        cell.secondBtn.isSelected = session.isMaintenance ?? false
        cell.secondBtn.setImage(UIImage(named: session.isMaintenance == true ? "checkBox" : "uncheck"), for: .normal)
        cell.clickImage?.tag = indexPath.row
        cell.clickImage?.addTarget(self, action: #selector(selectImageButtonTapped(_:)), for: .touchUpInside)
        cell.clickImage?.setImage(nil, for: .normal)
        if let imageName = session.image {
            let imageUrl = getDocumentsDirectory().appendingPathComponent(imageName)
            if let imageData = try? Data(contentsOf: imageUrl) {
                let image = UIImage(data: imageData)
                cell.clickImage?.setImage(image, for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension VisibilityVC: ImagePopForVisibilityDelegate {
    func didUpdateImage(image: UIImage, forIndex index: IndexPath) {
        if let imageData = image.jpegData(compressionQuality: 0.2) {
            let fileName = UUID().uuidString + ".png"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
            sessionModel[index.row].image = fileName
        }
        TableVw?.reloadRows(at: [index], with: .automatic)
    }
}

class VisibilityCell: UITableViewCell {
    @IBOutlet var headingLbl: UILabel!
    @IBOutlet var firstBtn: UIButton!
    @IBOutlet var secondBtn: UIButton!
    @IBOutlet var clickImage: UIButton?
    @IBOutlet var imgView: UIImageView?
    @IBOutlet var vW: UIView?
    weak var delegate: CheckboxCellDelegate?
    var indexPath: IndexPath!
    var parentVC: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vW?.dropShadow()
        firstBtn.setImage(UIImage(named: "uncheck"), for: .normal)
        secondBtn.setImage(UIImage(named: "uncheck"), for: .normal)
    }
    
    @IBAction func primaryCheckboxTapped(_ sender: UIButton) {
        toggleButtonImage(sender)
        DispatchQueue.main.async {
            self.delegate?.didToggleCheckbox(at: self.indexPath, isFirst: true, isChecked: sender.isSelected)
        }
    }
    
    @IBAction func secondaryCheckboxTapped(_ sender: UIButton) {
        toggleButtonImage(sender)
        DispatchQueue.main.async {
            self.delegate?.didToggleCheckbox(at: self.indexPath, isFirst: false, isChecked: sender.isSelected)
        }
    }
    
    private func toggleButtonImage(_ button: UIButton) {
        DispatchQueue.main.async {
            button.isSelected.toggle()
            let newImageName = button.isSelected ? "checkBox" : "uncheck"
            button.setImage(UIImage(named: newImageName), for: .normal)
        }
    }
}

class sessetmodel {
    var asset: String?
    var isPresent: Bool?
    var isMaintenance: Bool?
    var image: String?
}
























//import UIKit
//
//protocol CheckboxCellDelegate: AnyObject {
//    func didToggleCheckbox(at indexPath: IndexPath, isFirst: Bool, isChecked: Bool)
//}
//
//class VisibilityVC: UIViewController, CheckboxCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    @IBOutlet var TableVw: UITableView?
//    @IBOutlet var proceedBtn: UIButton?
//    @IBOutlet var txtView: UITextView?
//    var date: String?
//    var time: String?
//    var address: String?
//    var accountId: String = ""
//    var assetModel = [AssetModel]()
//    var onAssetsTable = OnAssetsTable()
//    var allVisibilityData: [AllVisibilityModel] = []
//    var sessionModel = [sessetmodel]()
//    var customDateFormatter = CustomDateFormatter()
//    var allVisibilityTable = AllVisibilityTable()
//    var selectedIndexPath: IndexPath?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        proceedBtn?.layer.masksToBounds = true
//        proceedBtn?.layer.cornerRadius = 8
//        TableVw?.delegate = self
//        TableVw?.dataSource = self
//        TableVw?.reloadData()
//        txtView?.dropShadow()
//        proceedBtn?.layer.cornerRadius = 8.0
//        proceedBtn?.layer.masksToBounds = true
//        txtView?.placeholder = "Enter text here"
//        txtView?.textColor = .darkGray
//        txtView?.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 13)
//        if assetModel.isEmpty {
//            print("assetModel is empty. Please check its initialization.")
//        } else {
//            initializeSessionModel()
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        assetModel = onAssetsTable.getAssets()
//        initializeSessionModel()
//    }
//
//    func initializeSessionModel() {
//        sessionModel = assetModel.map { asset in
//            let session = sessetmodel()
//            session.asset = asset.Label
//            session.isPresent = false
//            session.isMaintenance = false
//            return session
//        }
//        print("SessionModel initialized with \(sessionModel.count) items.")
//        TableVw?.reloadData()
//    }
//
//    func didToggleCheckbox(at indexPath: IndexPath, isFirst: Bool, isChecked: Bool) {
//        let session = sessionModel[indexPath.row]
//        if isFirst {
//            session.isPresent = isChecked
//        } else {
//            session.isMaintenance = isChecked
//        }
//        print("Updated \(session.asset ?? ""): isPresent = \(session.isPresent ?? false), isMaintenance = \(session.isMaintenance ?? false)")
//    }
//    
//    @objc func selectImageButtonTapped(_ sender: UIButton) {
//        let indexPathRow = sender.tag
//        let session = sessionModel[indexPathRow]
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = .camera
//            present(imagePicker, animated: true, completion: nil)
//        } else {
//            print("Camera is not available on this device")
//        }
//        
//        selectedIndexPath = IndexPath(row: indexPathRow, section: 0)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let selectedImage = info[.originalImage] as? UIImage else { return }
//
//        if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
//            let fileName = UUID().uuidString + ".jpg"
//            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
//            
//            do {
//                try imageData.write(to: fileURL)
//                if let indexPath = selectedIndexPath {
//                    sessionModel[indexPath.row].image = fileURL.absoluteString
//                    // Reload the specific row at the selected index path to update the UI
//                    TableVw?.reloadRows(at: [indexPath], with: .automatic)
//                }
//            } catch {
//                print("Error saving image: \(error)")
//            }
//        }
//
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    @IBAction func proceedAction() {
//        for session in sessionModel {
//            let visibilityModel = AllVisibilityModel(
//                LocalId: nil,
//                External_Id__c: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
//                outletId: currentVisitId,
//                assetName: session.asset,
//                addRemark: txtView?.text,
//                assetItemImg: session.image,  // Update with actual image if needed
//                isPresent: session.isPresent ?? false ? "1" : "0",
//                isMaintenance: session.isMaintenance ?? false ? "1" : "0",
//                isSync: "1",
//                createdAt: customDateFormatter.getFormattedDateForAccount()
//            )
//            allVisibilityData.append(visibilityModel)
//        }
//        allVisibilityTable.saveVisibility(models: allVisibilityData) { success, error in
//            if success {
//                self.skipAction()
//                SceneDelegate.getSceneDelegate().window?.makeToast(ADVOCACYREQ_CREATED)
//            } else {
//                SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
//            }
//        }
//    }
//    
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
//
//    @IBAction func backAction() {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func skipAction() {
//        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//        if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
//            self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
//        }
//    }
//}
//
//extension VisibilityVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sessionModel.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: VisibilityCell = tableView.dequeueReusableCell(withIdentifier: "VisibilityCell", for: indexPath) as! VisibilityCell
//        let session = sessionModel[indexPath.row]
//        cell.headingLbl?.text = session.asset
//        cell.indexPath = indexPath
//        cell.delegate = self
//        cell.parentVC = self
//        cell.firstBtn.isSelected = session.isPresent ?? false
//        cell.firstBtn.setImage(UIImage(named: session.isPresent == true ? "checkBox" : "uncheck"), for: .normal)
//        cell.secondBtn.isSelected = session.isMaintenance ?? false
//        cell.secondBtn.setImage(UIImage(named: session.isMaintenance == true ? "checkBox" : "uncheck"), for: .normal)
//        cell.clickImage?.tag = indexPath.row
//        cell.clickImage?.addTarget(self, action: #selector(selectImageButtonTapped(_:)), for: .touchUpInside)
//        cell.clickImage?.setImage(nil, for: .normal)
//        if let imageUrlString = session.image, let imageUrl = URL(string: imageUrlString), let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
//            cell.clickImage?.setImage(image, for: .normal)
//        }
//
//        return cell
//    }
//}
//
//class VisibilityCell: UITableViewCell {
//    @IBOutlet var headingLbl: UILabel!
//    @IBOutlet var firstBtn: UIButton!
//    @IBOutlet var secondBtn: UIButton!
//    @IBOutlet var clickImage: UIButton?
//    @IBOutlet var imgView: UIImageView?
//    @IBOutlet var vW: UIView?
//    weak var delegate: CheckboxCellDelegate?
//    var indexPath: IndexPath!
//    var parentVC: UIViewController?
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        vW?.dropShadow()
//        firstBtn.setImage(UIImage(named: "uncheck"), for: .normal)
//        secondBtn.setImage(UIImage(named: "uncheck"), for: .normal)
//    }
//    
//    @IBAction func primaryCheckboxTapped(_ sender: UIButton) {
//        toggleButtonImage(sender)
//        delegate?.didToggleCheckbox(at: indexPath, isFirst: true, isChecked: sender.isSelected)
//    }
//    
//    @IBAction func secondaryCheckboxTapped(_ sender: UIButton) {
//        toggleButtonImage(sender)
//        delegate?.didToggleCheckbox(at: indexPath, isFirst: false, isChecked: sender.isSelected)
//    }
//    
//    private func toggleButtonImage(_ button: UIButton) {
//        button.isSelected.toggle()
//        let newImageName = button.isSelected ? "checkBox" : "uncheck"
//        button.setImage(UIImage(named: newImageName), for: .normal)
//    }
//}
//class sessetmodel {
//    var asset: String?
//    var isPresent: Bool?
//    var isMaintenance: Bool?
//    var image: String?
//}
