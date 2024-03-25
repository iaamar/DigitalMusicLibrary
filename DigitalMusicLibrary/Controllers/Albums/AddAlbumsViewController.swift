//
//  AddAlbumsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData

class AddAlbumViewController: UIViewController, AlbumUpdateDelegate {

    func albumDidUpdate() {
        delegate?.albumDidUpdate()
    }
    
    @IBOutlet weak var albumNameTextField: UITextField!
 

    @IBOutlet weak var artistIdField: UITextField!
    
   
    @IBOutlet weak var releaseDate: UIDatePicker!
    
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
        delegate?.albumDidUpdate()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        let artistId = Int(artistIdField.text!)!
       
        if albumExists(albumNameTextField.text!) {
            showAlert(title: "Error", message: "album '\(String(describing: albumNameTextField.text))' already exists.")
            return
        }
        guard dataManager.artistsModel.first(where: { $0.id == dataManager.artistsModel[artistId-1].id }) != nil else {
            showAlert(title: "Error", message: "Artist with ID \(artistIdField.text) does not exist")
            return
        }
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        let releaseDateString = dateFormatter.string(from: releaseDate.date)
        addAlbum(title: albumNameTextField.text!, artistIndex: artistId, releaseDate: releaseDateString)
        
    }
    
    private func containsDigits(_ string: String) -> Bool {
        let range = string.rangeOfCharacter(from: .decimalDigits)
        return range != nil
    }
    
    private func albumExists(_ title: String) -> Bool {
        return dataManager.albumsModel.contains { $0.title?.lowercased() == title.lowercased() }
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
    
    // Function to add a new album
    func addAlbum(title: String, artistIndex: Int, releaseDate: String) {
        // Validate input
        guard !title.isEmpty else
        {
            showAlert(title: "Error", message: "Title cannot be empty")
            return
        }
        guard dataManager.artistsModel.count >= artistIndex else{
            showAlert(title: "Error", message: "Artist does not exist with index \(artistIndex)")
            return
        }
        let actualIndex = artistIndex - 1
 
        guard !releaseDate.isEmpty else {
            showAlert(title: "Error", message: "Release date cannot be empty")
            return
        }
        do{
            dataManager.addAlbum(albumtitle: title, releaseDate: releaseDate, artistId: dataManager.artistsModel[actualIndex].id!)
            showAlert(title: "Success", message: "Album Created!")
            delegate?.albumDidUpdate()
        }catch{
            showAlert(title: "Error", message: "Failed to add album: \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
 
}


