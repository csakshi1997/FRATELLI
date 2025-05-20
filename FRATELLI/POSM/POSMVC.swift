//
//  POSMVC.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit

class POSMVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    var contactsTable = ContactsTable()
    var contact = [Contact]()
    let sampleData = [
            "Short text.",
            "A longer paragraph that may span multiple lines. This text demonstrates how the cell height adjusts dynamically based on the amount of content inside the label.",
            "Another short text."
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    func setInitialUI() {
        TableVw?.showsVerticalScrollIndicator = false
        TableVw?.showsHorizontalScrollIndicator = false
        contact = contactsTable.getContacts()
        if contact.isEmpty {
            noDataVw?.isHidden = false
        } else {
            noDataVw?.isHidden = true
            TableVw?.reloadData()
        }
        TableVw?.rowHeight = UITableView.automaticDimension
        TableVw?.estimatedRowHeight = 100
    }
    
}

extension POSMVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: POSMCell = tableView.dequeueReusableCell(withIdentifier: "POSMCell", for: indexPath) as! POSMCell
        cell.configure(with: sampleData[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class POSMCell: UITableViewCell {
    @IBOutlet var outletLbl: UILabel?
    @IBOutlet var poshitemListLbl: UILabel?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        addButtonBorder()
    }
    
    func addButtonBorder() {
        vw?.dropShadow()
    }
    func configure(with text: String) {
        poshitemListLbl?.text = text
    }
}

