//
//  HeaderView.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-15.
//

import UIKit

@IBDesignable
class HeaderView: UIView {
    
    @IBOutlet weak var subHeaderView: UIView!
    @IBOutlet weak var statusTitleView: UIView!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var showDateOfBirth: UIImageView!
    @IBOutlet weak var invalidMessageLabel: UILabel!
    @IBOutlet weak var headerContentView: UIView!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var issuerLabel: UILabel!
    
    var dateOfBirth: String = ""
    
    private func loadNib() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.backgroundColor = .clear
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func setVerificationStatus(status: VerificationStatus, statusTitle: String, statusMessage: String){
        let statusColor = Theme.colors.colorFromVerificationStatus(verificationStatus: status)
        var statusImage: UIImage?
        
        switch status {
        case .VERIFIED:
            invalidMessageLabel.isHidden = true
            headerContentView.isHidden = false
            statusImage = UIImage(named: "result_verified")
        case .PARTIALLY_VERIFIED:
            invalidMessageLabel.isHidden = true
            headerContentView.isHidden = false
            statusImage = UIImage(named: "result_failed")
        case .NOT_VERIFIED:
            invalidMessageLabel.isHidden = false
            invalidMessageLabel.text = statusMessage
            headerContentView.isHidden = true
            statusImage = UIImage(named: "result_invalid")
        }
        
        statusTitleLabel.text = statusTitle
        statusMessageLabel.text = statusMessage
        statusImageView.image = statusImage
        
        statusTitleView.backgroundColor = statusColor
        subHeaderView.backgroundColor = statusColor
        self.backgroundColor = statusColor
        headerContentView.backgroundColor = statusColor
    }
    
    func populateView(shcresults: SmartHealthCardResults){
        self.fullNameLabel.text = shcresults.getPatientName()
        self.dateOfBirth = shcresults.getBirthDate()
        self.dateOfBirthLabel.text = shcresults.getBirthDateFormatted()
        self.issuerLabel.text = shcresults.iss
        
        setVerificationStatus(status: shcresults.verificationStatus, statusTitle: shcresults.statusText, statusMessage: shcresults.statusMessage)
        self.backgroundColor = Theme.colors.colorFromVerificationStatus(verificationStatus: shcresults.verificationStatus)
    }
    
    @objc func showDateOfBirthTapped(){
        let blockedDateOfBirth = String(dateOfBirth.map{ _ in return "•"})
        
        if let dateOfBirthString = dateOfBirthLabel.text {
            if dateOfBirthString.contains("•") {
                dateOfBirthLabel.text = dateOfBirth
                showDateOfBirth.image = UIImage(named: "eye_hide")
            }
            else {
                dateOfBirthLabel.text = blockedDateOfBirth
                showDateOfBirth.image = UIImage(named: "eye")
            }
        }
        else{
            print("Had a problem getting value from our dateOfBirthLabel")
        }
    }
    
    func setup(){
        loadNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDateOfBirthTapped))
        showDateOfBirth.addGestureRecognizer(tapGesture)
        showDateOfBirth.isUserInteractionEnabled = true
        
        showDateOfBirth.image = UserDefaults.standard.bool(forKey: Constants.SETTINGS_HIDE_DATEOFBIRTH) ? UIImage(named: "eye") : UIImage(named: "eye_hide")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
}
