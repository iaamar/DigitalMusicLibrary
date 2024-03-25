//
//  EditSongsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData

class EditSongViewController: UIViewController {
    var song: Songs?
    
    @IBOutlet weak var songTitle: UITextField!
    
    @IBOutlet weak var duration: UITextField!
    
    @IBOutlet weak var isFavourite: UITextField!
    
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
        songTitle.text = song?.title
        duration.text = String(song!.duration)
        var isFav = ""
        if song?.isfavourite == true{
            isFav = "1"
        } else{
            isFav = "0"
        }
        isFavourite.text = isFav
    }
    
    
    // Function to update an existing song
    func updateSong(song: Songs, title: String, duration: Double, isFavorite: Int) {
    
        guard !title.isEmpty else {
            showAlert(title: "Error", message: "Song title cannot be empty")
            return
        }
        guard !duration.isNaN && !duration.isZero else{
            showAlert(title: "Error", message: "Song duration format incorrect or empty")
            return
        }
        var isSongFavorite = false
        if isFavorite == 1 {
            isSongFavorite = true
        }else{
            isSongFavorite = false
        }
        dataManager.updateSong(title: title, duration: duration, isFav: isSongFavorite, updatedSong: song)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        let duration = Double(duration.text!)!
        var isSongFavorite = 0
        if isFavourite.text == "1" {
            isSongFavorite = 1
        }else{
            isSongFavorite = 0
        }
        do{
            updateSong(song: song!, title: songTitle.text!, duration: duration, isFavorite: isSongFavorite)
            showAlert(title: "Success", message: "Update Success!")
            delegate?.songDidUpdate()
        } catch {
                showAlert(title: "Error", message: "Failed to update songs: \(error.localizedDescription)")
            }
        }
    
    private func containsDigits(_ string: String) -> Bool {
        let range = string.rangeOfCharacter(from: .decimalDigits)
        return range != nil
    }
    
    private func songsExists(_ name: String) -> Bool {
        return dataManager.songsModel.contains { $0.title?.lowercased() == name.lowercased() }
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

    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
