//
//  SettingsViewController.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-10.
//

import UIKit
import Eureka

class SettingsViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        
        form +++ Section("About")
        
        <<< LabelRow(){ row in
            row.title = "Version"
            row.value = Common.getAppVersion()
        }
        
        <<< LabelRow(){ row in
            row.title = "Privacy Policy"
            
        }.onCellSelection({ cell, row in
            cell.row.deselect()
            Common.openURL(urlString: Constants.PRIVACY_URL)
            
        }).cellSetup({ cell, row in
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        })
        
        <<< LabelRow(){ row in
            row.title = "Terms of Use"
            
        }.onCellSelection({ cell, row in
            cell.row.deselect()
            Common.openURL(urlString: Constants.TERMS_URL)
            
        }).cellSetup({ cell, row in
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        })
        
        +++ Section("Options")
        
        <<< SwitchRow() { row in
            row.title = "Hide Date of Birth"
        }.onChange({ row in
            let userDefaults = UserDefaults.standard
            userDefaults.set(row.value, forKey: Constants.SETTINGS_HIDE_DATEOFBIRTH)
            userDefaults.synchronize()
        }).cellSetup({ cell, row in
            let userDefaults = UserDefaults.standard
            row.value = userDefaults.bool(forKey: Constants.SETTINGS_HIDE_DATEOFBIRTH)
            row.updateCell()
        })
    }
}
