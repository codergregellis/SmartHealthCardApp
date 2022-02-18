//
//  SmartHealthCard.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-15.
//

import Foundation

class SmartHealthCardRules {
    static let requiredDoses: Int = 2
    static let requiredDaysSinceLastDose: Int = 14
}

class SmartHealthCard: Codable {
    let iss: String
    let nbf: Decimal
    let vc: VaccineCard
    
    func getBirthDate() -> String{
        guard let dob = vc.credentialSubject.fhirBundle.entry.first?.resource.birthDate else { return "" }
        return dob
    }
    
    func getPatientName() -> String {
        var patientName: String = ""
        
        guard let name = vc.credentialSubject.fhirBundle.entry.first?.resource.name else { return "" }
        
        guard let given = name.first?.given else {
            return ""
        }
        
        for name in given {
            patientName += name + " "
        }
        
        if let family = name.first?.family {
            patientName += family
        }
        
        return patientName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct VaccineCard: Codable {
    let type: [String]
    let credentialSubject: CredentialSubject
    let rid: String
}

struct CredentialSubject: Codable {
    let fhirVersion: String
    let fhirBundle: FHIRBundle
}

struct FHIRBundle: Codable {
    let resourceType: String
    let type: String
    let entry: [Entry]
}

struct Entry: Codable {
    let fullUrl: String
    let resource: Resource
}

struct Resource: Codable {
    let resourceType: String
    let name: [Name]?
    let birthDate: String?
    let status: String?
    let vaccineCode: VaccineCode?
    let patient: Patient?
    let occurrenceDateTime: String?
    let performer: [Performer]?
    let lotNumber: String?
}

struct Name: Codable {
    let family: String?
    let given: [String]?
}

struct VaccineCode: Codable{
    let coding: [Coding]?
}

struct Patient: Codable {
    let reference: String?
}

struct Performer: Codable {
    let actor: Actor?
}

struct Coding: Codable{
    let system: String?
    let code: String?
}

struct Actor: Codable {
    let display: String?
}
