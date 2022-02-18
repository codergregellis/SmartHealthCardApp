//
//  Theme.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-10.
//

import Foundation
import UIKit

class Theme {
    class colors {
        
        class func colorFromVerificationStatus(verificationStatus: VerificationStatus) -> UIColor{
            switch verificationStatus {
            case .VERIFIED:
                return Verified()
            case .PARTIALLY_VERIFIED:
                return PartiallyVerified()
            case .NOT_VERIFIED:
                return NotVerified()
            }
        }
        
        class func Verified() -> UIColor {
            return UIColor(red: 16/255, green: 136/255, blue: 72/255, alpha: 1.0)
        }
        
        class func PartiallyVerified() -> UIColor {
            return .systemOrange
        }
        
        class func NotVerified() -> UIColor {
            return .systemRed
        }
        
        class func vaccineTitleBackgroundColor() -> UIColor {
            return UIColor(red: 76/255, green: 144/255, blue: 202/255, alpha: 1.0)
        }
        
        class func navigationBarBackgroundColor() -> UIColor {
            return UIColor(red: 0.0/255.0, green: 162.0/255.0, blue: 220/255.0, alpha: 1.0)
        }
    }
}
