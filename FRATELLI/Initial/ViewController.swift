//
//  ViewController.swift
//  FRATELLI
//
//  Created by Sakshi on 18/10/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var upperView: UIView!
    @IBOutlet var emailTxtFld: UITextField!
    @IBOutlet var passwordTxtFld: UITextField!
    @IBOutlet var submitBtn: UIButton!
    @IBOutlet var deviceIDBtn: UIButton?
    let validation = Validation()
    var userResponse : [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToDismissKeyboard()
        upperView.backgroundColor = UIColor(
            red: 114.0 / 255.0,
            green: 47.0 / 255.0,
            blue: 55.0 / 255.0,
            alpha: 0.78
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        deviceIDBtn?.setTitle("Device Id:- \(DeviceId)", for: .normal)
        upperView.roundCorners(corners: [.topLeft, .topRight], radius: 22)
        submitBtn.cornerRadius = 7
        emailTxtFld.placeholderColor = UIColor(textColor)
        passwordTxtFld.placeholderColor = UIColor(textColor)
        submitBtn.backgroundColor = UIColor(textColor)
        emailTxtFld?.setLeftPaddingPoints(15)
        emailTxtFld?.setRightPaddingPoints(15)
        passwordTxtFld?.setLeftPaddingPoints(15)
        passwordTxtFld?.setRightPaddingPoints(15)
        //        emailTxtFld.text = "abhinavkumar@fratelliwines.in"
        //        passwordTxtFld.text = "Abhinav@808"
        //                        emailTxtFld.text = "vijaybansode@fratelliwines.in"
        //                        passwordTxtFld.text = "Vijay@5295"
        //                         emailTxtFld.text = "deepeshmotiramani@fratelliwines.in"
        //                         passwordTxtFld.text = "Fratelli@1824"
        //                emailTxtFld.text = "sumitbhandary@fratelliwines.in"
        //                passwordTxtFld.text = "Bombay@1234"
        //                emailTxtFld.text = "seetharaman@fratelliwines.in.partialcop"
        //                passwordTxtFld.text = "again@123"
        //                emailTxtFld.text = "abhinavkumar@fratelliwines.in.partialcop"
        //                passwordTxtFld.text = "Dheeraj@123"
        //                emailTxtFld.text = "anjalisharma@fratelliwines.in"
        //                passwordTxtFld.text = "Anjali12345@"
        //                emailTxtFld.text = "hemantarora-qq9r@force.com.partialcop"
        //                passwordTxtFld.text = "Cloud@2024"
        //                emailTxtFld.text = "sambhajiwaghmare@fratelliwines.in"
        //                passwordTxtFld.text = "Sambhaji@1806"
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func validateFields() -> Bool {
        guard let email = emailTxtFld.text, !email.isEmpty else {
            self.view.makeToast("Please enter your email.")
            return false
        }
        
        if !validation.isValidEmail(email) {
            self.view.makeToast("Please enter a valid email.")
            return false
        }
        
        guard let password = passwordTxtFld.text, !password.isEmpty else {
            self.view.makeToast("Please enter your password.")
            return false
        }
        return true
    }
    
    @IBAction func signUpAction() {
        if validateFields() {
            logInAPI()
        }
    }
    
    @IBAction func deviceIdAction() {
        showAlert()
    }
    
    func showAlert() {
        let checkInalert = UIAlertController(
            title: "Info",
            message: "This is your device Id, Please send this to admin:\n\n\(DeviceId)",
            preferredStyle: .alert
        )
        
        checkInalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            print("OK tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Copy & WhatsApp", style: .default, handler: { _ in
            UIPasteboard.general.string = DeviceId
            print("Copied: \(DeviceId)")
            
            let message = "Hello, this is my device ID: \(DeviceId)"
            let urlString = "https://wa.me/?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("WhatsApp not installed or URL issue")
            }
        }))
        
        self.present(checkInalert, animated: true, completion: nil)
    }
    
    func goToSyncScreen() {
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "SyncVC") {
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
        
    func logInAPI() {
        self.view.endEditing(true)

        let authOperation = AuthOperation()
        let userData: [String: Any] = [
            "grant_type": grant_type,
            "client_id": client_id,
            "client_secret": client_secret,
            "username": emailTxtFld.text ?? EMPTY,
            "password": passwordTxtFld.text ?? EMPTY
        ]
print(userData)
        authOperation.executLogin(userDetail: userData) { error, response, status in
            switch status {
            case .success:
                self.userResponse = response ?? [:]
                guard let accessToken = self.userResponse["access_token"] as? String,
                      let instanceUrl = self.userResponse["instance_url"] as? String else {
                    self.view.makeToast("Invalid login response.")
                    return
                }
                Defaults.userEmail = self.emailTxtFld.text
                Defaults.userPassword = self.passwordTxtFld.text
                Defaults.accessToken = accessToken
                Defaults.instanceUrl = instanceUrl
                Defaults.signature = self.userResponse["signature"] as? String
                Defaults.tokenType = self.userResponse["token_type"] as? String
                let userIdToken = self.userResponse["id"] as? String ?? EMPTY
                
                let tokens = isProduction ?
                    self.validation.extractTokensForProduction(from: userIdToken) :
                    self.validation.extractTokens(from: userIdToken)
                
                Defaults.userId = tokens.uID
                Defaults.organizationToken = tokens.orgToken
                
                self.executeConfiguration()

            case .badRequest:
                let errorDescription = response?["error_description"] as? String
                self.view.makeToast(errorDescription)

            default:
                self.view.makeToast(error)
            }
        }
    }
        
    func executeConfiguration() {
        self.view.endEditing(true)

        guard !DeviceId.isEmpty else {
            self.view.makeToast("Device ID not available.")
            return
        }

        let authOperation = AuthOperation()
        let userData: [String: Any] = [
            "userId": Defaults.userId ?? "",
            "deviceId": DeviceId
        ]

        #if DEBUG
        print("Sending Device Data: \(userData)")
        #endif

        authOperation.sendDeviceToken(details: userData) { error, response, status in
            switch status {
            case .success:
                guard let response = response, let success = response["status"] as? Int, success == 1 else {
                    self.view.makeToast(response?["message"] as? String)
                    return
                }

                let userIdToken = self.userResponse["id"] as? String ?? EMPTY
                let tokens = isProduction ?
                    self.validation.extractTokensForProduction(from: userIdToken) :
                    self.validation.extractTokens(from: userIdToken)

                
                Defaults.isUserLoggedIn = true

                if Defaults.isAuthenticationfailedAtTheTimeOfSync ?? false {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let syncVC = storyboard.instantiateViewController(withIdentifier: "SyncInVC") as? SyncInVC {
                        self.navigationController?.pushViewController(syncVC, animated: true)
                    }
                } else {
                    self.goToSyncScreen()
                }

            case .error, .badRequest:
                let message = response?["message"] as? String ?? ERROR_OCCURRED
                self.view.makeToast(message)

            default:
                self.view.makeToast(error)
            }
        }
    }
}
