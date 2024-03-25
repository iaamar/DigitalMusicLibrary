//
//  File.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/5/24.
//
import Foundation
import UIKit
import CoreData

class DataStore {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let shared = DataStore()
    var artistsModel = [Artist]()
    var albumsModel = [Albums]()
    var genresModel = [Genres]()
    var songsModel = [Songs]()
    
    private init() {
        getAllArtists()
        getAllAlbums()
        getAllGenres()
        getAllSongs()
    }
    
    func getAllArtists() {
        do {
            artistsModel = try context.fetch(Artist.fetchRequest())
        }
        catch let error as NSError {
            print("Error fetching artists: \(error)")
        }
    }
    
    func deleteAllArtists() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Artists")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print("Error: \(error)")
        }
    }
    
    func addArtist(name: String) {
        let newArtist = Artist(context: context)
        newArtist.name = name
        newArtist.id = UUID()
        newArtist.albums = []
        do {
            try context.save()
            getAllArtists()
        }
        catch let error as NSError {
            print("Error adding new artist: \(error)")
        }
    }
    
    func updateArtist(artist: Artist, newName: String) {
        artist.name = newName
        do {
            try context.save()
            getAllArtists()
        }
        catch let error as NSError {
            print("Error updating the artist: \(error)")
        }
    }
    
    func deleteArtist(artist: Artist) {
        context.delete(artist)
        do {
            try context.save()
            getAllArtists()
        }
        catch let error as NSError {
            print("Error deleting the artist: \(error)")
        }
    }
    
    // Albums
    func fetchAlbums(forArtist artist: Artist) -> [Albums]? {
        let fetchRequest: NSFetchRequest<Albums> = Albums.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "artists == %@", artist)
        
        do {
            let albums = try context.fetch(fetchRequest)
            return albums
        } catch {
            print("Error fetching albums: \(error)")
            return nil
        }
    }
    
    func getAllAlbums() {
        do {
            albumsModel = try context.fetch(Albums.fetchRequest())
        }
        catch let error as NSError{
            print("Error fecthing albums: \(error)")
        }
    }
    
    func addAlbum(albumtitle: String, releaseDate: String, artistId: UUID) {
        let newAlbum = Albums(context: context)
        newAlbum.title = albumtitle
        newAlbum.id = UUID()
        newAlbum.releaseDate = releaseDate
        newAlbum.artistId = artistId
        newAlbum.songs = []
        do {
            try context.save()
            getAllAlbums()
        }
        catch let error as NSError {
            print("Error adding new album: \(error)")
        }
    }
    
    func updateAlbum(albumtitle: String, releaseDate: String, updatedAlbum: Albums) {
        updatedAlbum.title = albumtitle
        updatedAlbum.releaseDate = releaseDate
        updatedAlbum.songs = []
        do {
            try context.save()
            getAllAlbums()
        }
        catch let error as NSError {
            print("Error adding new album: \(error)")
        }
    }
    
    func deleteAlbum(album: Albums) {
        context.delete(album)
        do {
            try context.save()
            getAllAlbums()
        }
        catch let error as NSError {
            print("Error deleting the albums: \(error)")
        }
    }
    
    func deleteAllAlbums() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Albums")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
        } catch let error as NSError {
            // TODO: handle the error
            print("Error deleting the albums: \(error)")
        }
    }
    
    // Songs
    func getAllSongs() {
        do {
            songsModel = try context.fetch(Songs.fetchRequest())
        }
        catch let error as NSError{
            print("Error fecthing songs: \(error)")
        }
    }
    
    func addSong(title: String, albumId: UUID,genreId: UUID, artistId: UUID, duration: Double, isFav: Bool) {
        let newSong = Songs(context: context)
        newSong.title = title
        newSong.albumId = albumId
        newSong.genreId = genreId
        newSong.artistId = artistId
        newSong.duration = duration
        newSong.isfavourite = isFav
        newSong.id = UUID()
        
        do {
            try context.save()
            getAllSongs()
        }
        catch let error as NSError {
            print("Error adding new Song: \(error)")
        }
    }
    
    func updateSong(title: String, duration: Double, isFav: Bool, updatedSong: Songs) {
        updatedSong.title = title
        updatedSong.duration = duration
        updatedSong.isfavourite = isFav
        
        do {
            try context.save()
            getAllSongs()
        } catch let error as NSError {
            print("Error updating the song: \(error)")
        }
    }
    
    func deleteSong(song: Songs) {
        context.delete(song)
        do {
            try context.save()
            getAllSongs()
        } catch let error as NSError {
            print("Error deleting the song: \(error)")
        }
    }
    
    func deleteAllSongs() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Songs")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
        } catch let error as NSError {
            // TODO: handle the error
            print("Error deleting all songs: \(error)")
        }
    }
    
    // Genres
    func getAllGenres() {
        do {
            genresModel = try context.fetch(Genres.fetchRequest())
        }
        catch let error as NSError {
            print("Error fetching genres: \(error)")
        }
    }
    
    func deleteAllGenres() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Genres")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
        } catch let error as NSError {
            // TODO: handle the error
            print("Error: \(error)")
        }
    }
    
    func addGenre(name: String) {
        let newGenre = Genres(context: context)
        newGenre.name = name
        newGenre.id = UUID()
        do {
            try context.save()
            getAllGenres()
        }
        catch let error as NSError {
            print("Error adding new artist: \(error)")
        }
    }
    
    func updateGenre(genre: Genres, newName: String) {
        genre.name = newName
        do {
            try context.save()
            getAllGenres()
        }
        catch let error as NSError {
            print("Error updating the genre: \(error)")
        }
    }
    
    func deleteGenre(genre: Genres) {
        context.delete(genre)
        do {
            try context.save()
            getAllArtists()
        }
        catch let error as NSError {
            print("Error deleting the genre: \(error)")
        }
    }
}
