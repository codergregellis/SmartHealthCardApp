//
//  DatabaseManager.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-10.
//

import Foundation
import GRDB

class DatabaseManager {
    var dbName: String!
    var databasePath: URL!
    var dbQueue: DatabaseQueue!
    
    static let sharedInstance: DatabaseManager = {
        let instance = DatabaseManager()
        return instance
    }()
    
    class func shared() -> DatabaseManager {
        return sharedInstance
    }
    
    func excludeFromBackup(url: URL){
        var fileURL = url
        do {
            var res = URLResourceValues()
            res.isExcludedFromBackup = true
            try fileURL.setResourceValues(res)
        }
        catch {
            print("error excluding \(url.absoluteString) from backup")
        }
    }
    
    func copyDB() -> Bool {
        var retval = false
        let filename: NSString = dbName as NSString
        let ext = filename.pathExtension
        let name = filename.replacingOccurrences(of: ".\(ext)", with: "")
        
        do {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: databasePath.path) {
                if let dbFilePath = Bundle.main.path(forResource: name, ofType: ext) {
                    try fileManager.copyItem(atPath: dbFilePath, toPath: databasePath.path)
                    excludeFromBackup(url: databasePath)
                    retval = true
                }
                else{
                    retval = false
                    print("Uh oh - \(String(describing: dbName)) is not in the app bundle")
                }
            }
            else {
                retval = true
                print("Database file was found at path: \(databasePath.path)")
            }
        }
        catch {
            retval = false
        }
        
        return retval
    }
    
    func openDB() -> Bool {
        var retval = false
        do {
            dbQueue = try DatabaseQueue(path: databasePath.absoluteString)
            retval = true
            
        }
        catch {
            retval = false
        }
        return retval
    }
    
    func checkAndLoadDB(dbFileName: String) {
        dbName = dbFileName
        databasePath = Common.getDocumentsDirectoryAppend(text: dbName)
        
        if(copyDB()){
            if(!openDB()) {
                print("error opening database")
            }
            else{
                //upgrade the database if necessary
                print("database opened successfully!")
            }
        }
        else{
            print("error copying database")
        }
    }
    
    func getVaccineByCVX(cvx: Int) -> Vaccine? {
        var retVal: Vaccine? = nil
        
        guard let dbQueue = dbQueue else { return retVal }
        
        do {
            try dbQueue.read{ db in
                if let row = try Row.fetchOne(db, sql: "SELECT * FROM vaccine WHERE cvx = ? ", arguments: [cvx]) {
                    retVal = Vaccine(id: row["id"], name: row["name"], description: row["description"], cvx: row["cvx"])
                }
            }
        }
        catch{
            print("Error getting vaccine from cvx: \(error)")
        }
        
        return retVal
    }
}
