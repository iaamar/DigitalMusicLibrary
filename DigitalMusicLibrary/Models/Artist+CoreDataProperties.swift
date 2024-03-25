//
//  Artist+CoreDataProperties.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/16/24.
//
//

import Foundation
import CoreData


extension Artist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var albums: NSSet?

}

// MARK: Generated accessors for albums
extension Artist {

    @objc(addAlbumsObject:)
    @NSManaged public func addToAlbums(_ value: Albums)

    @objc(removeAlbumsObject:)
    @NSManaged public func removeFromAlbums(_ value: Albums)

    @objc(addAlbums:)
    @NSManaged public func addToAlbums(_ values: NSSet)

    @objc(removeAlbums:)
    @NSManaged public func removeFromAlbums(_ values: NSSet)

}

extension Artist : Identifiable {

}
