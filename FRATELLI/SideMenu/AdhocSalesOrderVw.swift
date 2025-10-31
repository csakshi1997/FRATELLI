//
//  AdhocSalesOrderVw.swift
//  FRATELLI
//
//  Created by Sakshi on 19/11/24.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import DropDown

class AdhocSalesOrderVw: UIViewController {
    @IBOutlet var outletTxtFld: MDCOutlinedTextField?
    @IBOutlet var distributorTxtFld: MDCOutlinedTextField?
    @IBOutlet var productTxtFld: MDCOutlinedTextField?
    @IBOutlet var schemeTxtFld: MDCOutlinedTextField?
    @IBOutlet var dateTxtFld: MDCOutlinedTextField?
    @IBOutlet var quantityTxtFld: MDCOutlinedTextField?
    @IBOutlet var schemePerventageTxtFld: MDCOutlinedTextField?
    @IBOutlet var freeIssueQuantityTxtFld: MDCOutlinedTextField?
    @IBOutlet var addBtn: UIButton?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var schemeTypeStack: UIStackView?
    @IBOutlet var schemePercentageStack: UIStackView?
    @IBOutlet var addItemeStack: UIStackView?
    @IBOutlet var vWHeight: NSLayoutConstraint?
    @IBOutlet var proceedBtn: UIButton?
    @IBOutlet var remarkTxtView: UITextView?
    @IBOutlet var vw: UIView?
    @IBOutlet var headerVw: UIView?
    var distributorAccountsTable = DistributorAccountsTable()
    var distributorAccountsModel: DistributorAccountsModel?
    var distributorAccountsModelArr = [DistributorAccountsModel]()
    var outletsTable = OutletsTable()
    var outlet: Outlet?
    var outletArr = [Outlet]()
    var productsTable = ProductsTable()
    var product = [Product]()
    var outletPickerData = [String]()
    var productPickerData = [String]()
    var outletNamesToIDs: [String: String] = [:]
    var productNamesToIDs: [String: String] = [:]
    var currentPickerData: [String] = []
    var outletId = ""
    var productId = ""
    var distributorId = ""
    var tableData: SalesOrderModel?
    var tableDataLineItems: [SalesOrderLineItems] = []
    var salesOrderTable = SalesOrderTable()
    var salesOrderLineItemsTable = SalesOrderLineItemsTable()
    var customDateFormatter = CustomDateFormatter()
    var percentage =  ""
    var quanityInBottles =  ""
    var amount =  ""
    var isQuality: Bool = false
    var zeroScheme: Bool = false
    var ispercentage: Bool = false
    var isAmount: Bool = false
    var dropdownManager = DropdownManager()
    var destributorDropdownManager = DropdownManager()
    let dropdown = DropDown()
    var outletPickerItems = [OutletPickerItem]()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
        distributorAccountsModelArr = distributorAccountsTable.getDistributorOutlets()
        outletArr = outletsTable.getOutlets()
        product = productsTable.getProducts()
        loadProductNames()
        if (outlet?.distributorName?.isEmpty ?? true) {
            distributorTxtFld?.isUserInteractionEnabled = true
            configureDropdownForDistributor()
        } else {
            distributorTxtFld?.text = outlet?.distributorName
            distributorTxtFld?.isUserInteractionEnabled = false
        }
        addTapGestureToDismissKeyboard()
        configureDropdownForProduct()
        loadOutletNames()
        configureDropdownForOutlet()
    }
    
    func loadOutletNames() {
        var seen = Set<String>()
        outletPickerItems = []
        for item in outletArr {
            let name = item.name ?? ""
            let id = item.id ?? ""
            let key = "\(name)_\(id)"
            if !seen.contains(key) {
                seen.insert(key)
                outletPickerItems.append(OutletPickerItem(name: name, id: id))
            }
        }
        dropdown.dataSource = outletPickerItems.map { $0.name }
    }
    
    func configureDropdownForProduct() {
        dropdownManager.setupDropdown(for: productTxtFld!, with: productNamesToIDs) { [weak self] (name, id) in
            self?.productTxtFld?.text = name
            self?.productId = id
            print("Selected product ID: \(id)")
        }
    }
    
    func configureDropdownForOutlet() {
        dropdown.anchorView = outletTxtFld
//        dropdown.dataSource = outletPickerData
        dropdown.dataSource = outletPickerItems.map { $0.name }
        dropdown.direction = .bottom
        dropdown.dismissMode = .automatic
        dropdown.bottomOffset = CGPoint(x: 0, y: (outletTxtFld?.frame.height ?? 0.0) + 25.0)
//        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
//            self.outletNameTxtFld?.text = item
//            if let outletID = outletNamesToIDs[item] {
//                self.outletId = outletID
//                print("Selected Outlet ID: \(outletID)")
//            }
//        }
        
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletTxtFld?.text = item
            let selectedItem = self.outletPickerItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }
    }
    
    func getUniqueDistributors(from outlets: [DistributorAccountsModel]) -> [(name: String, distributorPartyCode: String)] {
        let distributors = outlets.compactMap { (outlet) -> (String, String)? in
            guard let distributorName = outlet.name, !distributorName.isEmpty,
                  let distributorId = outlet.accountId, !distributorId.isEmpty else {
                print("Skipping distributor: \(outlet)")
                return nil
            }
            return (distributorName, distributorId)
        }
        let uniqueDistributorsNames = Set(distributors.map { $0.0 })
        let uniqueDistributorsWithPartyCodes = uniqueDistributorsNames.compactMap { name -> (String, String)? in
            if let outlet = outlets.first(where: { $0.name == name }) {
                print("Found outdistributorlet for distributor \(name): \(outlet)")
                return (name, outlet.accountId) as? (String, String)
            }
            return nil
        }
        return uniqueDistributorsWithPartyCodes
    }
        
    func configureDropdownForDistributor() {
        if !distributorAccountsModelArr.isEmpty {
            let uniqueDistributors = getUniqueDistributors(from: distributorAccountsModelArr)
            if uniqueDistributors.isEmpty { return }
            let distributorData = Dictionary(uniqueKeysWithValues: uniqueDistributors)
            guard let distributorTxtFld = distributorTxtFld else {
                print("Error: distributorTxtFld is nil")
                return
            }
            destributorDropdownManager.setupDropdown(for: distributorTxtFld, with: distributorData) { [weak self] (name, accountId) in
                print("Dropdown selected: \(name), \(accountId)")
                self?.distributorTxtFld?.text = name
                self?.distributorId = accountId
                print("Selected distributor  (ID): \(self?.distributorId ?? "")")
            }
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == productTxtFld {
            if textField.text?.isEmpty ?? true {
                dropdownManager.filterDropdown(with: "")
            }
            dropdownManager.showDropdown()
        } else if textField == distributorTxtFld, let query = textField.text {
            destributorDropdownManager.filterDropdown(with: query)
            destributorDropdownManager.showDropdown()
        } else if textField == outletTxtFld {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dropdown.show()
            }
            
        } else if textField == schemeTxtFld {
            textField.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)
                let vc = storyBoard.instantiateViewController(identifier: "SchemeTypeView") as! SchemeTypeView
                vc.modalPresentationStyle = .overFullScreen
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                
                vc.completionHandler = { concernText in
                    self.schemeTxtFld?.text = concernText
                    //                    self.updateSchemeFields()
                    
                    switch self.schemeTxtFld?.text {
                    case "Scheme with VAT/ED":
                        self.schemePercentageStack?.isHidden = false
                        self.vWHeight?.constant = 460
                        self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
                        self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
                        self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
                        self.quanityInBottles = ""
                        self.amount = ""
                        self.isQuality = false
                        self.zeroScheme = false
                        self.ispercentage = true
                        self.isAmount = false
                    case "Scheme without VAT/ED":
                        self.schemePercentageStack?.isHidden = false
                        self.vWHeight?.constant = 460
                        self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
                        self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
                        self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
                        self.quanityInBottles = ""
                        self.amount = ""
                        self.isQuality = false
                        self.zeroScheme = false
                        self.ispercentage = true
                        self.isAmount = false
                    case "Scheme on MRP":
                        self.schemePercentageStack?.isHidden = false
                        self.vWHeight?.constant = 460
                        self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
                        self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
                        self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
                        self.quanityInBottles = ""
                        self.amount = ""
                        self.isQuality = false
                        self.zeroScheme = false
                        self.ispercentage = true
                        self.isAmount = false
                    case "Free Issue with VAT/ED":
                        self.schemePercentageStack?.isHidden = false
                        self.vWHeight?.constant = 460
                        self.freeIssueQuantityTxtFld?.label.text = "Free Issue Quantity(In btls.)"
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
                        self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
                        self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
                        self.percentage = ""
                        self.amount = ""
                        self.isQuality = true
                        self.zeroScheme = false
                        self.ispercentage = false
                        self.isAmount = false
                    case "Free Issue without VAT/ED":
                        self.schemePercentageStack?.isHidden = false
                        self.vWHeight?.constant = 460
                        self.freeIssueQuantityTxtFld?.label.text = "Free Issue Quantity(In btls.)"
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
                        self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
                        self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
                        self.percentage = ""
                        self.amount = ""
                        self.isQuality = true
                        self.zeroScheme = false
                        self.ispercentage = false
                        self.isAmount = false
                    case "Flat Amount Scheme":
                        self.schemePercentageStack?.isHidden = false
                        self.vWHeight?.constant = 460
                        self.freeIssueQuantityTxtFld?.label.text = "Total Amount (INR)"
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
                        self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
                        self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
                        self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
                        self.amount = self.freeIssueQuantityTxtFld?.text ?? ""
                        self.percentage = ""
                        self.quanityInBottles = ""
                        self.isQuality = false
                        self.zeroScheme = false
                        self.ispercentage = false
                        self.isAmount = true
                    case "Zero Scheme":
                        self.schemePercentageStack?.isHidden = true
                        self.isQuality = false
                        self.zeroScheme = true
                        self.ispercentage = false
                        self.isAmount = false
                    default:
                        return
                    }
                    
                    
                }
                
                self.present(vc, animated: true, completion: nil)
            }
            return false // Prevents keyboard from showing
        }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == productTxtFld, let query = textField.text {
            dropdownManager.filterDropdown(with: query)
            dropdownManager.showDropdown()
        } else if textField == distributorTxtFld, let query = textField.text {
            destributorDropdownManager.filterDropdown(with: query)
            destributorDropdownManager.showDropdown()
        } else if textField == outletTxtFld, let query = textField.text {
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == outletTxtFld else { return true }

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        let filteredItems: [OutletPickerItem]
        if updatedText.isEmpty {
            filteredItems = outletPickerItems
        } else {
            filteredItems = outletPickerItems.filter { $0.name.lowercased().contains(updatedText.lowercased()) }
        }

        dropdown.dataSource = filteredItems.map { $0.name }
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletTxtFld?.text = item
            let selectedItem = filteredItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }

        dropdown.show()
        return true
    }
    
    func loadProductNames() {
        productPickerData = product.map { $0.name ?? "" }
        productNamesToIDs = Dictionary(uniqueKeysWithValues: product.map { ($0.name ?? "", $0.id ?? "") })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func quantityIncsDecs(isIncrement: Bool, quantity: Int) {
        var quantityInc = quantity
        if isIncrement {
            quantityInc += 1
        } else {
            quantityInc = max(0, quantityInc - 1)
        }
        quantityTxtFld?.text = "\(quantityInc)"
    }
    
    func setInitialUI(){
        addTapGestureToDismissKeyboard()
        proceedBtn?.layer.cornerRadius = 8.0
        proceedBtn?.layer.masksToBounds = true
        vw?.layer.cornerRadius = 8
        vw?.layer.masksToBounds = true
        outletTxtFld?.label.text = "Outlet Name"
        outletTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        outletTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        outletTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        outletTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        outletTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        distributorTxtFld?.label.text = "Distributor Name"
        distributorTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        distributorTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        distributorTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        distributorTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        distributorTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        productTxtFld?.label.text = "Product Name"
        productTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        productTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        productTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        productTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        productTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        schemeTxtFld?.label.text = "Scheme Type"
        schemeTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        schemeTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        schemeTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        schemeTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        schemeTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        quantityTxtFld?.label.text = "Quantity (In Bottles)"
        quantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        quantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        quantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        quantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        quantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        schemePerventageTxtFld?.label.text = "Scheme %"
        schemePerventageTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        schemePerventageTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        schemePerventageTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        schemePerventageTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        schemePerventageTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        dateTxtFld?.label.text = "Select Date"
        dateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        dateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        dateTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        dateTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        dateTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        schemePercentageStack?.isHidden = true
        vWHeight?.constant = 410
        headerVw?.isHidden = true
        outletTxtFld?.delegate = self
        productTxtFld?.delegate = self
        outletTxtFld?.setRightPaddingPoints(30)
        distributorTxtFld?.setRightPaddingPoints(30)
        productTxtFld?.setRightPaddingPoints(30)
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        let today = Calendar.current.startOfDay(for: Date())
        let twoDaysAgo = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -2, to: today)!)
        datePicker.maximumDate = today
        datePicker.minimumDate = twoDaysAgo
        dateTxtFld?.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        dateTxtFld?.inputAccessoryView = toolbar
        productTxtFld?.delegate = self
    }
    
    @objc func donePressed() {
        let selectedDate = datePicker.date
        let today = Date()
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        if selectedDate >= twoDaysAgo && selectedDate <= today {
            dateChanged()
            dateTxtFld?.resignFirstResponder()
        } else {
            showAlert()
        }
    }
    
    @objc func dateChanged() {
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTxtFld?.text = formatter.string(from: selectedDate)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Invalid Date", message: "Please select a date within the last two days only.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @IBAction func doneButtonTapped() {
        view.endEditing(true)  
    }
    
    @IBAction func submitAction() {
        print(tableData ?? "")
        if !tableDataLineItems.isEmpty {
            let storyboardBundle = Bundle.main
            let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
            let dashboardVC = storyboard.instantiateViewController(withIdentifier: "PreviewOrderVw") as! PreviewOrderVw
            dashboardVC.salesModel = tableData
            dashboardVC.salesModelLineItems = tableDataLineItems
            dashboardVC.isSideMenu = true
            self.navigationController?.pushViewController(dashboardVC, animated: true)
        } else {
            let checkOutalert = UIAlertController(
                title: "Alert",
                message: "Please order atleast one Product",
                preferredStyle: .alert
            )
            self.present(checkOutalert, animated: true, completion: nil)
            checkOutalert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            }))
            
        }
    }

    private func clearTextFields() {
        outletTxtFld?.text = ""
        distributorTxtFld?.text = ""
        productTxtFld?.text = ""
        schemeTxtFld?.text = ""
        quantityTxtFld?.text = ""
        schemePerventageTxtFld?.text = ""
    }
    
    func gotoSchemeType() {
        self.view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle:nil)
        let vc = (storyBoard.instantiateViewController(identifier: "SchemeTypeView")) as! SchemeTypeView
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3966007864)
        vc.completionHandler = { concernText in
//            self.concernTxtFld?.text = concernText
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func incDecrement(_ sender: UIButton) {
        let quantityText = quantityTxtFld?.text ?? ""
        let quantityInt = Int(quantityText)
        let currentQuantity = Int(quantityTxtFld?.text ?? "0") ?? 0
        if sender.tag == 1 {
            quantityIncsDecs(isIncrement: true, quantity: quantityInt ?? 0)
        } else {
            quantityIncsDecs(isIncrement: false, quantity: quantityInt ?? 0)
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonAction() {
        if let distributor = distributorTxtFld?.text, distributor.isEmpty {
            showAlert(title: "Error", message: "Please add Distributor.")
            return
        }
        
        if let product = productTxtFld?.text, product.isEmpty {
            showAlert(title: "Error", message: "Product not found.")
            return
        }
        
        if let quantity = quantityTxtFld?.text, quantity.isEmpty {
            showAlert(title: "Error", message: "Please fill Product Quantity.")
            return
        }
        
        if let quantity = quantityTxtFld?.text, quantity == "0" {
            showAlert(title: "Error", message: "Quantity Should be greater than zero")
            return
        }
        
        if let scheme = schemeTxtFld?.text, scheme.isEmpty {
            showAlert(title: "Error", message: "Please fill Scheme Type.")
            return
        }
        
        if !zeroScheme {
            if let schemePercentage = freeIssueQuantityTxtFld?.text, schemePercentage.isEmpty, ispercentage {
                showAlert(title: "Error", message: "Please fill Scheme Percentage.")
                return
            }
            
            if let schemePercentage = freeIssueQuantityTxtFld?.text, schemePercentage.isEmpty, isQuality {
                showAlert(title: "Error", message: "Please fill Free Issue Qty (In Btls).")
                return
            }
            
            if let schemePercentage = freeIssueQuantityTxtFld?.text, schemePercentage.isEmpty, isAmount {
                showAlert(title: "Error", message: "Please fill Total Amount.")
                return
            }
        }
        switch self.schemeTxtFld?.text {
        case "Scheme with VAT/ED":
            
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Scheme without VAT/ED":
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Scheme on MRP":
            
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Free Issue with VAT/ED":
            
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Free Issue without VAT/ED":
            
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Flat Amount Scheme":
            
            self.amount = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Zero Scheme":
            self.schemePercentageStack?.isHidden = true
        default:
            return
        }
        prepareSalesModelData()
    }
    
    func prepareSalesModelData () {
        view.endEditing(true)
//        guard let distributor = distributorTxtFld?.text, !distributor.isEmpty,
//              let product = productTxtFld?.text, !product.isEmpty,
//              let scheme = schemeTxtFld?.text, !scheme.isEmpty,
//              let quantity = quantityTxtFld?.text, !quantity.isEmpty,
//              let schemePercentage = freeIssueQuantityTxtFld?.text, !schemePercentage.isEmpty else {
//            showAlert(title: "Error", message: "Please fill in all fields.")
//            return
//        }
        tableData = SalesOrderModel(
            localId: nil,
            External_Id__c: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
            Bulk_Upload__c: true,
            Distributor__Id: !distributorId.isEmpty ? distributorId : "",
            DistributorName: distributorTxtFld?.text,
            Customer__Id: outlet?.accountId,
            customerName: outlet?.name,
            Employee_Code__c: outlet?.salesmanCode,
            Order_Booking_Data__c: CustomDateFormatter.getCurrentDateTime(),
            Distributor_Party_Code__c: outlet?.distributorPartyCode,
            Customer_Party_Code__c: outlet?.partyCode,
            Status__c: "Submitted",
            dateTime: customDateFormatter.getFormattedDateForAccount(),
            ownerId: Defaults.userId,
            addRemark: remarkTxtView?.text,
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            isSync: "0",
            Visit_Date_c: "",
            Visit_Order_c: ""
        )
        prepareSalesModelLineItemsData()
    }
    
    func prepareSalesModelLineItemsData () {
        view.endEditing(true)
        let newDataLineItems = SalesOrderLineItems(
            localId: nil,
            External_Id__c: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
            Product__ID: productId,
            Product_Name: productTxtFld?.text,
            Scheme_Type__c: schemeTxtFld?.text,
            Total_Amount_INR__c: amount,
            Free_Issue_Quantity_In_Btls__c: quanityInBottles,
            Scheme_Percentage__c: percentage,
            Product_quantity_c: quantityTxtFld?.text,
            dateTime: customDateFormatter.getFormattedDateForAccount(),
            ownerId: Defaults.userId,
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            isSync: "0"
        )
        tableDataLineItems.append(newDataLineItems)
        if tableDataLineItems.count > 0 {
            tableView?.reloadData()
            headerVw?.isHidden = false
        }
        clearTextFields()
    }
}

extension AdhocSalesOrderVw: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataLineItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AdhocSalesOrderCell = tableView.dequeueReusableCell(withIdentifier: "AdhocSalesOrderCell", for: indexPath) as! AdhocSalesOrderCell
        let backgroundImage = UIImage(named: "bg")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        cell.backgroundView = backgroundImageView
        let data = tableDataLineItems[indexPath.row]
        cell.nameLbl?.text = data.Product_Name
        cell.quantityLbl?.text = data.Product_quantity_c
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class AdhocSalesOrderCell: UITableViewCell {
    @IBOutlet var nameLbl: UILabel?
    @IBOutlet var quantityLbl: UILabel?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
    }
}


extension AdhocSalesOrderVw: UITextFieldDelegate {
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == schemeTxtFld {
//            textField.resignFirstResponder()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                //            self.view.endEditing(true)
//                //            textField.resignFirstResponder()
//                let storyBoard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle:nil)
//                let vc = (storyBoard.instantiateViewController(identifier: "SchemeTypeView")) as! SchemeTypeView
//                vc.modalPresentationStyle = .overFullScreen
//                vc.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3966007864)
//                vc.completionHandler = { concernText in
//                    self.schemeTxtFld?.text = concernText
//                    self.schemeTxtFld?.text
//                }
//                self.present(vc, animated: false, completion: nil)
//            }
//        }
//    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool r
    
    func updateSchemeFields() {
        switch self.schemeTxtFld?.text {
        case "Scheme with VAT/ED":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
            self.quanityInBottles = ""
            self.amount = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = true
            self.isAmount = false
        case "Scheme without VAT/ED":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
            self.quanityInBottles = ""
            self.amount = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = true
            self.isAmount = false
        case "Scheme on MRP":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
            self.quanityInBottles = ""
            self.amount = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = true
            self.isAmount = false
        case "Free Issue with VAT/ED":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Free Issue Quantity(In btls.)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
            self.percentage = ""
            self.amount = ""
            self.isQuality = true
            self.zeroScheme = false
            self.ispercentage = false
            self.isAmount = false
        case "Free Issue without VAT/ED":
            self.freeIssueQuantityTxtFld?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Free Issue Quantity(In btls.)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
            self.percentage = ""
            self.amount = ""
            self.isQuality = true
            self.zeroScheme = false
            self.ispercentage = false
            self.isAmount = false
        case "Flat Amount Scheme":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Total Amount (INR)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.amount = self.freeIssueQuantityTxtFld?.text ?? ""
            self.percentage = ""
            self.quanityInBottles = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = false
            self.isAmount = true
        case "Zero Scheme":
            self.schemePercentageStack?.isHidden = true
            self.isQuality = false
            self.zeroScheme = true
            self.ispercentage = false
            self.isAmount = false
        default:
            return
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if textField == schemeTxtFld  {
            schemePercentageStack?.isHidden = false
            vWHeight?.constant = 460
        }
    }
    
    
}
