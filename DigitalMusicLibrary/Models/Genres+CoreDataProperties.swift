//
//  Genres+CoreDataProperties.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/16/24.
//
//

import Foundation
import CoreData


extension Genres {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Genres> {
        return NSFetchRequest<Genres>(entityName: "Genres")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}

extension Genres : Identifiable {

}
