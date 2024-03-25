//
//  ArtistDetailsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit

class ArtistDetailsViewController: UIViewController, ArtistUpdateDelegate {
    func artistDidUpdate() {
        delegate?.artistDidUpdate()
    }
    
    var dataManager = DataStore.shared

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    var artist: Artist?
    
    weak var delegate: ArtistUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.artistDidUpdate()
        if let artist = artist {
            artistNameLabel.text = artist.name
            let randomIndex =  Int.random(in: 1...8)
            let imageName = "artist\(randomIndex)"
            if let image = UIImage(named: imageName){
                imageView.image = image
                imageView.layer.cornerRadius = 15
                imageView.clipsToBounds = true
                imageView.layer.shadowColor = UIColor.black.cgColor
                imageView.layer.shadowOpacity = 0.5
                imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
                imageView.layer.shadowRadius = 4
                imageView.layer.masksToBounds = false
            } else {
                imageView.image = UIImage(named: "defaultImage")
            }
        }
        
    }
    
    @IBAction func onEditButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "editArtist", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editArtist" {
            if let editArtistVC = segue.destination as? EditArtistViewController {
                editArtistVC.delegate = self
                editArtistVC.artist = artist
            }
        }
    }
    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
        if let artist = artist {

            let isArtistUsed = dataManager.albumsModel.contains(where: { $0.artistId == artist.id })
            if isArtistUsed {
                showAlert(title: "Error", message: "Selected artist is associated with one or more album and cannot be deleted")
                return
            }
            do {
                dataManager.deleteArtist(artist: artist)
                showAlert(title: "Success", message: "Artist Deleted!")
                delegate?.artistDidUpdate() // Call delegate method after deleting artist
            } catch {
                showAlert(title: "Error", message: "Failed to delete artist: \(error.localizedDescription)")
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
