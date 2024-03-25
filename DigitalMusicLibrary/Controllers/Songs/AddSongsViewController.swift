//
//  AddSongsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData



class AddSongViewController: UIViewController, SongUpdateDelegate {

    func songDidUpdate() {
        delegate?.songDidUpdate()
    }
    
    @IBOutlet weak var songNameTextField: UITextField!
 

    @IBOutlet weak var artistIdField: UITextField!
    
    @IBOutlet weak var albumIdFiled: UITextField!
    
    @IBOutlet weak var genreIdField: UITextField!
    
    @IBOutlet weak var durationField: UITextField!
    
    @IBOutlet weak var favouriteField: UITextField!
    
    var dataManager = DataStore.shared
    var managedObjectContext: NSManagedObjectContext!
    weak var delegate: SongUpdateDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        delegate?.songDidUpdate()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        let artistId = Int(artistIdField.text!)!
        let albumId = Int(albumIdFiled.text!)!
        let genreId = Int(genreIdField.text!)!
        let duration = Double(durationField.text!)!
        let isFavourite = Int(favouriteField.text!)!
        if songExists(songNameTextField.text!) {
            showAlert(title: "Error", message: "song '\(String(describing: songNameTextField.text))' already exists.")
            return
        }
        addSong(title: songNameTextField.text!, artistId: artistId, albumId: albumId, genreId: genreId, duration: duration, isFavorite: isFavourite)
        
        
//        guard let songName = songNameTextField.text, !songName.isEmpty else {
//            showAlert(title: "Error", message: "song name cannot be empty")
//            return
//        }
//
//        if containsDigits(songName) {
//            showAlert(title: "Error", message: "song name cannot contain numbers")
//            return
//        }
//
//        if songExists(songName) {
//            showAlert(title: "Error", message: "song '\(songName)' already exists.")
//            return
//        }
//        let actualArtistId = artistIdField.text!
//        let artistIndex = Int(actualArtistId)! - 1
//        let actualAlbumId = albumIdFiled.text!
//        let albumIndex = Int(actualAlbumId)! - 1
//        let actualGenreId = genreIdField.text!
//        let genreIndex = Int(actualGenreId)! - 1
//        guard dataManager.artistsModel.first(where: { $0.id == dataManager.artistsModel[artistIndex].id }) != nil else {
//            showAlert(title: "Error", message: "Artist with ID \(artistIdField) does not exist")
//            return
//        }
//
//        guard dataManager.albumsModel.first(where: { $0.id == dataManager.albumsModel[albumIndex].id }) != nil else {
//            showAlert(title: "Error", message: "Album with ID \(albumIdFiled) does not exist")
//            return
//        }
//
//        guard dataManager.songsModel.first(where: { $0.id == dataManager.songsModel[genreIndex].id }) != nil else {
//            showAlert(title: "Error", message: "Genre with ID \(genreIdField) does not exist")
//            return
//        }
//        var isFav:Bool = false
//        if favouriteField.text == "1" {
//            isFav = true
//        }else{
//            isFav = false
//        }
//        guard case durationField.text = durationField.text, !durationField.text!.isEmpty else {
//            showAlert(title: "Error", message: "Song duration empty")
//            return
//        }
//
//        if ((durationField.text?.isNumeric) != nil) {
//            if ((durationField.text?.isDouble) != nil) || ((durationField.text?.isInteger) != nil) {
//                if let doubleValue = Double(durationField.text!), !doubleValue.isNaN && !doubleValue.isZero{
//                    showAlert(title: "Error", message: "Song duration format incorrect or empty. Enter a integer or double value only")
//                    return
//                }
//            }
//        }
//        dataManager.addSong(title: songNameTextField.text, albumId: alb, genreId: <#T##UUID#>, artistId: <#T##UUID#>, duration: <#T##Double#>, isFav: <#T##Bool#>)
//        songNameTextField.text = ""
//        delegate?.songDidUpdate()
    }
    
    private func containsDigits(_ string: String) -> Bool {
        let range = string.rangeOfCharacter(from: .decimalDigits)
        return range != nil
    }
    
    private func songExists(_ title: String) -> Bool {
        return dataManager.songsModel.contains { $0.title?.lowercased() == title.lowercased() }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        }
    
    // Function to add a new song
    func addSong(title: String, artistId: Int, albumId: Int, genreId: Int, duration: Double, isFavorite: Int) {
        // Validate input
        guard !title.isEmpty else {
            showAlert(title: "Error", message: "Song title cannot be empty")
            return
        }
        
        guard dataManager.artistsModel.first(where: { $0.id == dataManager.artistsModel[artistId - 1].id }) != nil else {
            showAlert(title: "Error", message: "Artist with ID \(artistId) does not exist")
            return
        }
        
        guard dataManager.albumsModel.first(where: { $0.id == dataManager.albumsModel[albumId - 1].id }) != nil else {
            showAlert(title: "Error", message: "Album with ID \(albumId) does not exist")
            return
        }
        
        guard dataManager.songsModel.first(where: { $0.id == dataManager.songsModel[genreId - 1].id }) != nil else {
            showAlert(title: "Error", message: "Genre with ID \(genreId) does not exist")
            return
        }
        do{
            dataManager.addSong(title: title, albumId: dataManager.albumsModel[albumId - 1].id!, genreId: dataManager.songsModel[genreId - 1].id!, artistId: dataManager.artistsModel[artistId - 1].id!, duration: duration, isFav: (isFavorite != 0))
        showAlert(title: "Success", message: "Song Added!!")
            
        } catch{
                showAlert(title: "Error", message: "Failed to delete genre: \(error.localizedDescription)")
            }
    }

    @IBAction func onBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
 
}
