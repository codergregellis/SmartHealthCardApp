//
//  Vaccine.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-16.
//

import Foundation
import GRDB

class Vaccine: Record, Codable {
    var id: Int?
    var name: String
    var description: String
    var cvx: Int
    
    init(id: Int? = nil, name: String, description: String, cvx: Int){
        self.id = id
        self.name = name
        self.description = description
        self.cvx = cvx
        super.init()
    }
    
    override class var databaseTableName: String { "vaccine" }
    
    private enum Columns: CodingKey {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let cvx = Column(CodingKeys.cvx)
    }
    
    required init(row: Row) {
        id = row[Columns.id]
        name = row[Columns.name]
        description = row[Columns.name]
        cvx = row[Columns.cvx]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.description] = description
        container[Columns.cvx] = cvx
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }
}
