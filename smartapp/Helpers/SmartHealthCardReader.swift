//
//  SmartHealthCardReader.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-15.
//

import Foundation
import UIKit
import JOSESwift
import CryptoKit

class SmartHealthCardReader{
    
    static let sharedInstance: SmartHealthCardReader = {
        let instance = SmartHealthCardReader()
        return instance
    }()
    
    class func shared() -> SmartHealthCardReader {
        return sharedInstance
    }
    
    private func parseJWS(qrCodeString: String) -> JWS? {
        do {
            guard qrCodeString.starts(with: Constants.SMART_HEALTH_CARD_PREFIX) else {
                return nil
            }
            
            let numbers = qrCodeString.replacingOccurrences(of: Constants.SMART_HEALTH_CARD_PREFIX, with: "")
            let final = numbers.transformFromNumericMode(every: 2)
            let jws = try JWS(compactSerialization: final)
            return jws
        }
        catch{
            print("Error parsing JWS: \(error)")
            return nil
        }
    }
    
    private func getJWKS(issuerURL: String, kid: String, completion: @escaping(Result<Key?, Error>) -> Void){
        var retKey: Key? = nil
        
        Common.loadJson(fromURLString: issuerURL) { result in
            switch result {
            case .success(let data):
                
                if let content = String(data: data, encoding: .utf8) {
                    do {
                        if let jsonData = content.data(using: .utf8) {
                            let jwksObject = try JSONDecoder().decode(PublicKeys.self, from: jsonData)
                            for key in jwksObject.keys {
                                if let jwksid = key.kid {
                                    if jwksid == kid {
                                        retKey = key
                                        break
                                    }
                                }
                            }
                        }
                        
                        if retKey != nil {
                            completion(.success(retKey))
                        }
                        else {
                            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Key was not found"])))
                        }
                    }
                    catch{
                        print("Error decoding public keys into JSON: \(error)")
                        completion(.failure(error))
                    }
                }
                
                break
            case .failure(let error):
                print("Error loading JSON from URL: \(error)")
                completion(.failure(error))
                break
            }
        }
    }
    
    private func generatePublicKey(jws: JWS, key: Key) -> SecKey? {
        var pk: SecKey?
        
        let attributesECPub: [String:Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256
        ]
        
        if var xStr = key.x, var yStr = key.y {
            xStr = xStr.sanitizeBase64()
            yStr = yStr.sanitizeBase64()
            
            if let x:[UInt8] = Data.init(base64Encoded: xStr)?.bytes, let y:[UInt8] = Data.init(base64Encoded: yStr)?.bytes {
                let i : [UInt8] = [0x04]
                
                let pubBytes = i + x + y
                var error: Unmanaged<CFError>?
                pk = SecKeyCreateWithData(Data.init(pubBytes) as CFData, attributesECPub as CFDictionary, &error)! as SecKey
            }
        }
        
        return pk
    }
    
    private func validateJWS(jws: JWS, key: Key) -> Bool {
        var retVal: Bool = false
        
        if let publicKey = generatePublicKey(jws: jws, key: key) {
            if let verifier = Verifier(verifyingAlgorithm: .ES256, key: publicKey) {
            
                do {
                    _ = try jws.validate(using: verifier)
                    retVal = true
                    print("Smart Health Card Cryptographic Signature Verified!")
                }
                catch JOSESwiftError.signatureInvalid {
                    print("Error verifying cryptographic signature")
                }
                catch{
                    print("Unknown error verifying cyrptographic signature \(error)")
                }
            }
        }
        
        return retVal
    }
    
    private func populateSmartHealthCardStatus(shc: SmartHealthCard, shcresults: SmartHealthCardResults, valid: Bool) {
        if valid == true {
            shcresults.iss = shc.iss
            shcresults.birthDate = shc.getBirthDate()
            shcresults.patientName = shc.getPatientName()
            
            for entry in shc.vc.credentialSubject.fhirBundle.entry {
                if entry.resource.resourceType == "Immunization" {
                    shcresults.immunizationEntries.append(entry)
                }
            }
            
            if shcresults.immunizationEntries.count >= SmartHealthCardRules.requiredDoses {
                var daysSince = 0
                
                for entry in shcresults.immunizationEntries {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let doseDate = entry.resource.occurrenceDateTime {
                        if let date = dateFormatter.date(from: doseDate){
                            
                            let days = Common.daysBetween(start: date, end: Date())
                            if daysSince == 0 || days < daysSince {
                                daysSince = days
                            }
                            
                            if daysSince >= SmartHealthCardRules.requiredDaysSinceLastDose {
                                shcresults.verificationStatus = .VERIFIED
                                shcresults.statusText = Constants.VERIFICATION_STATUS_VERIFIED
                                shcresults.statusMessage = Constants.VERIFICATION_STATUS_MESSAGE_VERIFIED
                            }
                            else {
                                shcresults.verificationStatus = .PARTIALLY_VERIFIED
                                shcresults.statusText = Constants.VERIFICATION_STATUS_PARTIALLY_VERIFIED
                                shcresults.statusMessage = "Last dose was less than \(SmartHealthCardRules.requiredDaysSinceLastDose) day(s) ago."
                            }
                        }
                        else {
                            shcresults.verificationStatus = .PARTIALLY_VERIFIED
                            shcresults.statusText = Constants.VERIFICATION_STATUS_PARTIALLY_VERIFIED
                            shcresults.statusMessage = "Unable to verify if last dose was \(SmartHealthCardRules.requiredDaysSinceLastDose) day(s) ago."
                        }
                    }
                    else {
                        shcresults.verificationStatus = .PARTIALLY_VERIFIED
                        shcresults.statusText = Constants.VERIFICATION_STATUS_PARTIALLY_VERIFIED
                        shcresults.statusMessage = "Unable to verify if last dose was \(SmartHealthCardRules.requiredDaysSinceLastDose) day(s) ago."
                    }
                }
            }
            else {
                shcresults.verificationStatus = .PARTIALLY_VERIFIED
                shcresults.statusText = Constants.VERIFICATION_STATUS_PARTIALLY_VERIFIED
                shcresults.statusMessage = "Does not have required minimum of \(SmartHealthCardRules.requiredDoses) doses."
            }
        }
        else {
            shcresults.verificationStatus = .NOT_VERIFIED
            shcresults.statusText = Constants.VERIFICATION_STATUS_NOT_VERIFIED
            shcresults.statusMessage = Constants.VERIFICATION_STATUS_MESSAGE_NOT_VERIFIED
        }
    }
    
    private func verifySmartHealthCard(jws: JWS, shc: SmartHealthCard, shcresults: SmartHealthCardResults, completion: @escaping (Bool) -> Void){
        let issuerURL = shc.iss + "/.well-known/jwks.json"
        
        guard let kid = jws.header.kid else {
            completion(false)
            return
        }
        
        getJWKS(issuerURL: issuerURL, kid: kid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let key):
                
                if let key = key {
                    let valid = self.validateJWS(jws: jws, key: key)
                    self.populateSmartHealthCardStatus(shc: shc, shcresults: shcresults, valid: valid)
                    
                    completion(valid)
                }
                else {
                    print("Error retreiving public keys")
                    self.populateSmartHealthCardStatus(shc: shc, shcresults: shcresults, valid: false)
                    completion(false)
                }
                
                break
            case .failure(let error):
                self.populateSmartHealthCardStatus(shc: shc, shcresults: shcresults, valid: false)
                completion(false)
                print("Error retreiving public keys \(error)")
                break
            }
        }
    }
    
    func parseSmartHealthCard(qrCodeString: String, completion: @escaping (SmartHealthCardResults?) -> Void){
        let smarthealthcardresults = SmartHealthCardResults()
        
        if let jws = parseJWS(qrCodeString: qrCodeString) {
            do {
                let uncompressed = try (jws.payload.data() as NSData).decompressed(using: .zlib)
                guard let str = String.init(data: uncompressed as Data, encoding: .utf8) else {
                    completion(smarthealthcardresults)
                    return
                }
                
                guard let jsonData = str.data(using: .utf8) else {
                    completion(smarthealthcardresults)
                    return
                }
                
                let shc = try JSONDecoder().decode(SmartHealthCard.self, from: jsonData)
                
                verifySmartHealthCard(jws: jws, shc: shc, shcresults: smarthealthcardresults) { success in
                    completion(smarthealthcardresults)
                }
            }
            catch{
                print("Error: \(error)")
                completion(smarthealthcardresults)
            }
        }
        else{
            completion(smarthealthcardresults)
        }
    }
}
