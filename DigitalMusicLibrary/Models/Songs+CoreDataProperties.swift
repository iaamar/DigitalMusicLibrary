//
//  Songs+CoreDataProperties.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/16/24.
//
//

import Foundation
import CoreData


extension Songs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Songs> {
        return NSFetchRequest<Songs>(entityName: "Songs")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var duration: Double
    @NSManaged public var title: String?
    @NSManaged public var genreId: UUID?
    @NSManaged public var albumId: UUID?
    @NSManaged public var artistId: UUID?
    @NSManaged public var isfavourite: Bool

}

extension Songs : Identifiable {

}
