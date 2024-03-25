//
//  EditArtistViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData


class EditArtistViewController: UIViewController {
    var artist: Artist?
    @IBOutlet weak var artistNameTextField: UITextField!
    var dataManager = DataStore.shared
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet weak var backButton: UIButton!
    weak var delegate: ArtistUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        artistNameTextField.text = artist?.name
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let artistName = artistNameTextField.text, !artistName.isEmpty else {
            showAlert(title: "Error", message: "Artist name cannot be empty")
            return
        }
        
        if containsDigits(artistName) {
            showAlert(title: "Error", message: "Artist name cannot contain numbers")
            return
        }
        
        if artistExists(artistName) {
            showAlert(title: "Error", message: "Artist '\(artistName)' already exists.")
            return
        }
        do{
            dataManager.updateArtist(artist: artist!, newName: artistNameTextField.text!)
            showAlert(title: "Success", message: "Update Success!")
            delegate?.artistDidUpdate()
        } catch {
                showAlert(title: "Error", message: "Failed to update artist: \(error.localizedDescription)")
            }
        }
    
    private func containsDigits(_ string: String) -> Bool {
        let range = string.rangeOfCharacter(from: .decimalDigits)
        return range != nil
    }
    
    private func artistExists(_ name: String) -> Bool {
        return dataManager.artistsModel.contains { $0.name?.lowercased() == name.lowercased() }
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
