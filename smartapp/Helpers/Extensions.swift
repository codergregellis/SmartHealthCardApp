//
//  Extensions.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-11.
//

import Foundation
import UIKit

extension String {
    
    func transformFromNumericMode(every n: Int) -> String {
        var result: String = ""
        
        let characters = Array(self)
        for x in stride(from: 0, to: characters.count, by: n) {
            var sub = String(characters[x..<min(x+n, characters.count)])
            let code = Int(sub) ?? 0
            sub = String(format: "%c", code+45)
            result += sub
        }
        return result
    }
    
    func sanitizeBase64() -> String {
        var retStr = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        if retStr.count % 4 == 2 {
            retStr.append("==")
        }
        
        if retStr.count % 4 == 3 {
            retStr.append("=")
        }
        return retStr
    }
}

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

extension Date {
    func getFormattedDate(format: String) -> String{
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
