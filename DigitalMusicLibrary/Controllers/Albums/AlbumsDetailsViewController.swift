//
//  AlbumsDetailsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData


class AlbumDetailsViewController: UIViewController, AlbumUpdateDelegate {

    func albumDidUpdate() {
        delegate?.albumDidUpdate()
    }

    var dataManager = DataStore.shared
    
    var albums: [Albums] = []
    var songs: [Songs] = []
    var artists: [Artist] = []
    var genres: [Genres] = []
    
    @IBOutlet weak var albumtitleLabel: UILabel!
    
    @IBOutlet weak var aritistIdLabel: UILabel!
    
    @IBOutlet weak var relaseDateLabel: UILabel!
    
    @IBOutlet weak var songListLabel: UILabel!
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var album: Albums?
    
    weak var delegate: AlbumUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.albumDidUpdate()
        if let album = album {
            let randomIndex =  Int.random(in: 1...8)
            let imageName = "album\(randomIndex)"
            if let image = UIImage(named: imageName){
                albumImageView.image = image
                albumImageView.layer.cornerRadius = 15
                albumImageView.clipsToBounds = true
                albumImageView.layer.shadowColor = UIColor.black.cgColor
                albumImageView.layer.shadowOpacity = 0.5
                albumImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
                albumImageView.layer.shadowRadius = 4
                albumImageView.layer.masksToBounds = false
            } else {
                albumImageView.image = UIImage(named: "defaultImage")
            }
        }
        albumtitleLabel.text = "Album: " + (album?.title)!
        aritistIdLabel.text = "Artist: " + getArtistName(for: (album?.artistId)!)
        relaseDateLabel.text = "Release Date: " + (album?.releaseDate)!
        songListLabel.text = "Song's: " + getSongsList(for: (album?.id)!)
    }
    
    func getSongsList(for albumID: UUID) -> String {
        let songsInAlbum = dataManager.songsModel.filter { $0.albumId == albumID }
        let albumNames = songsInAlbum.map { $0.title ?? "" }
        return albumNames.isEmpty ? "No songs associated" : albumNames.joined(separator: ", ")
    }
    func getArtistName(for artistId: UUID) -> String {
        guard let artist = artists.first(where: { $0.id == artistId }) else {
            return "\(artistId)"
        }
        return artist.name ?? "\(artistId)"
    }
    
    func getAlbumTitle(for albumId: UUID) -> String {
        guard let album = albums.first(where: { $0.id == albumId }) else {
            return "\(albumId)"
        }
        return album.title ?? "\(albumId)"
    }

    @IBAction func onEditButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "editAlbum", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editAlbum" {
            if let editAlbumVC = segue.destination as? EditAlbumViewController {
                editAlbumVC.delegate = self
                editAlbumVC.album = album
            }
        }
    }
    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
        if let album = album {
            let associatedSongs = dataManager.songsModel.filter { $0.albumId == album.id }
            if !associatedSongs.isEmpty {
                showAlert(title: "Error", message: "Selected album is associated with one or more songs and cannot be deleted")
                return
            } else {
                do {
                    dataManager.deleteAlbum(album: album)
                    showAlert(title: "Success", message: "Album Deleted!")
                    delegate?.albumDidUpdate()
                } catch {
                    showAlert(title: "Error", message: "Failed to delete album: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func backButtonPRessed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

