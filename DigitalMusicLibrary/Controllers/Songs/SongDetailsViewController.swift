//
//  SongDetailsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData


class SongDetailsViewController: UIViewController, SongUpdateDelegate {

    func songDidUpdate() {
        delegate?.songDidUpdate()
    }

    var dataManager = DataStore.shared
    
    var songs: [Songs] = []
    var albums: [Albums] = []
    var artists: [Artist] = []
    var genres: [Genres] = []
    
    @IBOutlet weak var songtitleLabel: UILabel!
    
    @IBOutlet weak var aritistIdLabel: UILabel!
    
    @IBOutlet weak var albumIdLabel: UILabel!
    
    @IBOutlet weak var genreIdLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var favouriteLabel: UILabel!
    
    @IBOutlet weak var songImageView: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var song: Songs?
    
    weak var delegate: SongUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.songDidUpdate()
        if let song = song {
            songtitleLabel.text =  "Song Title: " + song.title!
            aritistIdLabel.text = "Artist: " + getArtistName(for: song.artistId!)
            albumIdLabel.text = "Album: " + getAlbumTitle(for: song.albumId!)
            genreIdLabel.text = "Genre: " +  getGenreName(for: song.genreId!)
            durationLabel.text = "Duration: " + String(song.duration)
            favouriteLabel.text = "Is Favourite: " + String(song.isfavourite)
            
            let randomIndex =  Int.random(in: 1...8)
            let imageName = "song\(randomIndex)"
            if let image = UIImage(named: imageName){
                songImageView.image = image
                songImageView.layer.cornerRadius = 15
                songImageView.clipsToBounds = true
                songImageView.layer.shadowColor = UIColor.black.cgColor
                songImageView.layer.shadowOpacity = 0.5
                songImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
                songImageView.layer.shadowRadius = 4
                songImageView.layer.masksToBounds = false
            } else {
                songImageView.image = UIImage(named: "defaultImage")
            }
        }
        
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
    
    func getGenreName(for genreId: UUID) -> String {
        guard let genre = dataManager.genresModel.first(where: { $0.id == genreId }) else {
            return "\(genreId)"
        }
        return genre.name ?? ""
    }
    @IBAction func onEditButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "editSong", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editSong" {
            if let editSongVC = segue.destination as? EditSongViewController {
                editSongVC.delegate = self
                editSongVC.song = song
            }
        }
    }
    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
        if let song = song {
            do {
                dataManager.deleteSong(song: song)
                showAlert(title: "Success", message: "Song Deleted!")
                delegate?.songDidUpdate()
            } catch {
                showAlert(title: "Error", message: "Failed to delete genre: \(error.localizedDescription)")
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
