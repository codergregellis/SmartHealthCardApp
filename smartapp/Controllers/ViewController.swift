//
//  ViewController.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-10.
//

import UIKit
import SwiftQRScanner
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var btnScan: CustomButton!
    
    func alertPromptToAllowCameraAccess(){
        let alert = UIAlertController(title: "Allow Camera Access", message: "Access to the camera has been disabled for this app. In order to use this app you must tap the Settings button and allow access to the camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { alert in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { result in
                
            }
        }))
        
        present(alert, animated: true)
    }
    
    func startScanner(){
        let scanner = QRCodeScannerController(cameraImage: UIImage(named: "camera"), cancelImage: nil, flashOnImage: UIImage(named: "flash"), flashOffImage: UIImage(named: "flash-off"))
        scanner.delegate = self
        scanner.modalPresentationStyle = .fullScreen
        self.present(scanner, animated: true)
    }
    
    @IBAction func btnScanTapped(_ sender: Any) {
        let session = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        if session.devices.count > 0 {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authStatus {
            case .notDetermined:
                startScanner()
            case .restricted:
                alertPromptToAllowCameraAccess()
            case .denied:
                alertPromptToAllowCameraAccess()
            case .authorized:
                startScanner()
            }
        }
        else{
            
            #if targetEnvironment(simulator)
            processResults(result: Constants.SMART_HEALTH_CARD_TEST)
            
            #else
            let alert = UIAlertController(title: "Warning", message: "It appears your device does not have a camera. Your device must have a camera in order to use this app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            #endif
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "Verifier"
    }
}

extension ViewController: QRScannerCodeDelegate {
    
    func processResults(result: String){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "resultsViewController") as! ResultsViewController
        SmartHealthCardReader.shared().parseSmartHealthCard(qrCodeString: result) { [weak self] shcresults in
            guard let self = self else { return }
            if let shcresults = shcresults {
                DispatchQueue.main.async {
                    vc.shcresults = shcresults
                    vc.parentController = self
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        processResults(result: result)
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        print("error: \(error)")
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
}
