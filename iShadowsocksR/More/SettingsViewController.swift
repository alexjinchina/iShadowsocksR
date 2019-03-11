//
//  MoreViewController.swift
//
//  Created by LEI on 1/23/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

import UIKit
import Eureka
import Appirater
import ICSMainFramework
import MessageUI
import SafariServices
import PotatsoLibrary

enum FeedBackType: String, CustomStringConvertible {
    case Email = "Email"
    case Forum = "Forum"
    case None = ""
    
    var description: String {
        return rawValue.localized()
    }
}



class SettingsViewController: FormViewController, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate {
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "More".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: SubscribeManager.subscriptionSettingsUpdatedNotification), object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.generateForm()
        }
        generateForm()
    }
    
    func generateForm() {
        form.delegate = nil
        form.removeAll()
        //        form +++ generateManualSection()
        //        form +++ generateSyncSection()
        form +++ generateSubscribeSection()
        //        form +++ generateRateSection()
        form +++ generateAboutSection()
        form.delegate = self
        tableView?.reloadData()
    }
    
    //    func generateManualSection() -> Section {
    //        let section = Section()
    //        section
    //            <<< ActionRow {
    //                $0.title = "User Manual".localized()
    //            }.onCellSelection({ [unowned self] (cell, row) in
    //                self.showUserManual()
    //            })
    ////            <<< ActionRow {
    ////                $0.title = "Feedback".localized()
    ////            }.onCellSelection({ (cell, row) in
    ////                FeedbackManager.shared.showFeedback()
    ////            })
    //        return section
    //    }
    
    func generateSyncSection() -> Section {
        let section = Section()
        section
            <<< ActionRow() {
                $0.title = "Sync".localized()
                $0.value = SyncManager.shared.currentSyncServiceType.rawValue
                }.onCellSelection({ [unowned self] (cell, row) -> () in
                    SyncManager.shared.showSyncVC(inVC: self)
                })
            <<< ActionRow() {
                $0.title = "Import From URL".localized()
                }.onCellSelection({ [unowned self] (cell, row) -> () in
                    let importer = Importer(vc: self)
                    importer.importConfigFromUrl()
                })
            <<< ActionRow() {
                $0.title = "Import From QRCode".localized()
                }.onCellSelection({ [unowned self] (cell, row) -> () in
                    let importer = Importer(vc: self)
                    importer.importConfigFromQRCode()
                })
        return section
    }
    
    func generateSubscribeSection()->Section{
        let section = Section()
        section
            <<< ActionRow() {
                $0.title = "Subscribe".localized()
                //                $0.value = SyncManager.shared.currentSyncServiceType.rawValue
                }.onCellSelection({ [unowned self] (cell, row) -> () in
                    SubscribeManager.shared.update()
                    
                    self.showProgreeHUD("Updating proxies...".localized())
//                    Async.background(after: 1) {
//                        SubscribeManager.shared.update()
////                        self.
////                        let config = Config()
////                        do {
////                            if isURL {
////                                if let url = URL(string: source) {
////                                    try config.setup(url: url)
////                                }
////                            }else {
////                                try config.setup(string: source)
////                            }
////                            try config.save()
////                            self.onConfigSaveCallback(true, error: nil)
////                        }catch {
////                            self.onConfigSaveCallback(false, error: error)
////                        }
//                    }
                    self.hideHUD()
                })
            <<< ActionRow() {
                $0.title = "URL".localized()
                $0.value = SubscribeManager.shared.subscribeUrl
                }.onCellSelection({ [unowned self] (cell, row) -> () in
                    
                    var urlTextField: UITextField?
                    let alert = UIAlertController(title: "Set Proxy subscribe URL".localized(), message: nil, preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.placeholder = "Input URL".localized()
                        urlTextField = textField
                    }
                    alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { (action) in
                        if let input = urlTextField?.text {
                            SubscribeManager.shared.subscribeUrl = input
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                })
        
        return section
    }
    
    func generateAboutSection() -> Section {
        let section = Section()
        section
            <<< LabelRow() {
                $0.title = "Version".localized()
                $0.value = AppEnv.fullVersion
        }
        return section
    }
    
    
    @objc func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
