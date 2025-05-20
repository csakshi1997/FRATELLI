//
//  OutletDetailsVC.swift
//  FRATELLI
//
//  Created by Sakshi on 26/11/24.
//

import UIKit

class OutletDetailsVC: UIViewController {
    @IBOutlet var stac1: UIStackView?
    @IBOutlet var stac2: UIStackView?
    @IBOutlet var stac3: UIStackView?
    @IBOutlet var stac4: UIStackView?
    @IBOutlet var stac5: UIStackView?
    @IBOutlet var stac6: UIStackView?
    @IBOutlet var actionItme: UIButton?
    @IBOutlet var meetGreet: UIButton?
    @IBOutlet var annualtargetDataLbl: UILabel?
    @IBOutlet var lastVisitDataLbl: UILabel?
    @IBOutlet var yearToDateSaleCurrentLbl: UILabel?
    @IBOutlet var yearToDateSaleLastYearLbl: UILabel?
    @IBOutlet var growthYearLbl: UILabel?
    @IBOutlet var marketShareLbl: UILabel?
    var accountId : String = ""
    var outletsTable = OutletsTable()
    var completionHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    func setInitialUI() {
        let outlets = outletsTable.getOutletData(forAccountId: accountId)
        annualtargetDataLbl?.text = (((outlets?.annualTargetData?.isEmpty ?? true) || (outlets?.annualTargetData == "0")) ? "0.0%" : outlets?.annualTargetData)
        lastVisitDataLbl?.text = ((outlets?.lastVisitDate?.isEmpty ?? true) ? "" : outlets?.lastVisitDate)
                                     yearToDateSaleCurrentLbl?.text = (((outlets?.years?.isEmpty ?? true) || (outlets?.years == "0")) ? "0.0%"  : outlets?.years)
        yearToDateSaleLastYearLbl?.text = (((outlets?.yearLastYear?.isEmpty ?? true) || (outlets?.yearLastYear == "0")) ? "0.0%" : outlets?.yearLastYear)
        growthYearLbl?.text = (((outlets?.growth?.isEmpty ?? true) || (outlets?.growth == "0")) ? "0.0%" : outlets?.growth)
        marketShareLbl?.text = (((outlets?.marketShare?.isEmpty ?? true) || (outlets?.marketShare == "0")) ? "0.0%" : outlets?.marketShare)
        stac1?.layer.cornerRadius = 10.0
        stac1?.layer.masksToBounds = true
        stac2?.layer.cornerRadius = 10.0
        stac2?.layer.masksToBounds = true
        stac3?.layer.cornerRadius = 10.0
        stac3?.layer.masksToBounds = true
        stac4?.layer.cornerRadius = 10.0
        stac4?.layer.masksToBounds = true
        stac5?.layer.cornerRadius = 10.0
        stac5?.layer.masksToBounds = true
        stac6?.layer.cornerRadius = 10.0
        stac6?.layer.masksToBounds = true
        actionItme?.layer.cornerRadius = 10.0
        actionItme?.layer.masksToBounds = true
        meetGreet?.layer.cornerRadius = 10.0
        meetGreet?.layer.masksToBounds = true
        stac1?.dropShadow()
        stac2?.dropShadow()
        stac3?.dropShadow()
        stac4?.dropShadow()
        stac6?.dropShadow()
        actionItme?.dropShadow()
        meetGreet?.dropShadow()
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func meetGreetAction() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let MeetGreetVC = storyboard.instantiateViewController(withIdentifier: "MeetGreetVC") as? MeetGreetVC {
            MeetGreetVC.accountId = accountId
            navigationController?.pushViewController(MeetGreetVC, animated: true)
        }
    }
    
    @IBAction func actionItemsAction() {
        self.view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        let vc = (storyBoard.instantiateViewController(identifier: "ActionItemPopUp")) as! ActionItemPopUp
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3966007864)
        vc.completionHandlerr = { [weak self] in
            guard let self = self else { return }
            let nextVC = self.storyboard?.instantiateViewController(identifier: "AddNewTasksVC") as! AddNewTasksVC
            nextVC.isFromActionItemPopup = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        self.present(vc, animated: false, completion: nil)
    }
    

   

}
