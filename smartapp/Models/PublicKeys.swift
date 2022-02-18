//
//  PublicKeys.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-15.
//

import Foundation

struct PublicKeys: Codable{
    let keys: [Key]
}

struct Key: Codable {
    let alg: String
    let kty: String?
    let kid: String?
    let use: String?
    let crv: String?
    let x: String?
    let y: String?
}
