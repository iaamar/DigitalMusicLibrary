//
//  Albums+CoreDataProperties.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/16/24.
//
//

import Foundation
import CoreData


extension Albums {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Albums> {
        return NSFetchRequest<Albums>(entityName: "Albums")
    }

    @NSManaged public var artistId: UUID?
    @NSManaged public var id: UUID?
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String?
    @NSManaged public var songs: NSSet?

}

// MARK: Generated accessors for songs
extension Albums {

    @objc(addSongsObject:)
    @NSManaged public func addToSongs(_ value: Songs)

    @objc(removeSongsObject:)
    @NSManaged public func removeFromSongs(_ value: Songs)

    @objc(addSongs:)
    @NSManaged public func addToSongs(_ values: NSSet)

    @objc(removeSongs:)
    @NSManaged public func removeFromSongs(_ values: NSSet)

}

extension Albums : Identifiable {

}
