//
//  Item+CoreDataProperties.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var confidence: Double
    @NSManaged public var text: String?
    @NSManaged public var imageData: NSData?

}
