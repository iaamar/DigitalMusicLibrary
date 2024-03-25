//
//  EditAlbumsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData

class EditAlbumViewController: UIViewController {
    var album: Albums?
    
    @IBOutlet weak var albumTitle: UITextField!
    
    @IBOutlet weak var releaseDatePicker: UIDatePicker!
    
    
    var dataManager = DataStore.shared
    var managedObjectContext: NSManagedObjectContext!
    weak var delegate: AlbumUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        albumTitle.text = album?.title
        
    }
    
    
 func updateAlbum(album: Albums, title: String, releaseDate: String) {
    
    // Validate input
    guard !title.isEmpty else {
        showAlert(title: "Error", message: "Album title cannot be empty")
        return
    }
    
     guard !releaseDatePicker.date.description.isEmpty else {
        showAlert(title: "Error", message: "Release date cannot be empty")
        return
    }
    dataManager.updateAlbum(albumtitle: title, releaseDate: releaseDate, updatedAlbum: album)
}

    @IBAction func addButtonTapped(_ sender: UIButton) {
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"

        let releaseDateString = dateFormatter.string(from: releaseDatePicker.date)
        do{
            updateAlbum(album: album!, title: albumTitle.text!, releaseDate: releaseDateString)
            showAlert(title: "Success", message: "Update Success!")
            delegate?.albumDidUpdate()
        } catch {
                showAlert(title: "Error", message: "Failed to update albums: \(error.localizedDescription)")
            }
        }
    
    private func containsDigits(_ string: String) -> Bool {
        let range = string.rangeOfCharacter(from: .decimalDigits)
        return range != nil
    }
    
    private func albumsExists(_ name: String) -> Bool {
        return dataManager.albumsModel.contains { $0.title?.lowercased() == name.lowercased() }
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

