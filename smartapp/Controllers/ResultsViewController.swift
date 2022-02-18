//
//  ResultsViewController.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-15.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tableView: UITableView!
    weak var parentController: ViewController?
    
    @IBAction func btnScanNextTaped(_ sender: Any) {
        dismiss(animated: false) {
            if self.parentController != nil {
                self.parentController?.btnScanTapped(self.parentController?.btnScan as Any)
            }
        }
    }
    
    var shcresults: SmartHealthCardResults?
    var entries: Array<Entry> = Array<Entry>()
    
    func setupUI(){
        if let shcresults = shcresults {
            entries = shcresults.immunizationEntries
            self.headerView.populateView(shcresults: shcresults)
        }
        else {
            print("results was nil (should not happen)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let entry = entries[section]
        var doseTitle = ""
        if let dateTimeString = entry.resource.occurrenceDateTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateTimeString) {
                doseTitle = "Dose \(section + 1) - \(date.getFormattedDate(format: "MMM d, yyyy"))"
            }
        }
        
        return doseTitle
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        header?.textLabel?.textColor = .white
        header?.contentView.backgroundColor = Theme.colors.vaccineTitleBackgroundColor()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as! VaccineTableViewCell
        let entry = entries[indexPath.section]
        
        guard let lotNumber = entry.resource.lotNumber else {
            return cell
        }
        
        guard let issuer = entry.resource.performer?.first?.actor?.display else {
            return cell
        }
        
        guard let vaccineCode = entry.resource.vaccineCode?.coding?.first?.code else {
            return cell
        }
        
        cell.lotNumberLabel.text = "Lot #\(lotNumber)"
        cell.issuerLabel.text = issuer
        
        if let vaccine = DatabaseManager.shared().getVaccineByCVX(cvx: Int(vaccineCode) ?? 0) {
            cell.manufacturerLabel.text = vaccine.description
        }
        
        return cell
    }
}
