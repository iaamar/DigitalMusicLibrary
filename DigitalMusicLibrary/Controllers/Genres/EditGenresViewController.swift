//
//  EditGenresViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData


class EditGenreViewController: UIViewController {
    var genre: Genres?
    @IBOutlet weak var genreNameTextField: UITextField!
    var dataManager = DataStore.shared
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet weak var backButton: UIButton!
    weak var delegate: GenreUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        genreNameTextField.text = genre?.name
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let genreName = genreNameTextField.text, !genreName.isEmpty else {
            showAlert(title: "Error", message: "genre name cannot be empty")
            return
        }
        
        if containsDigits(genreName) {
            showAlert(title: "Error", message: "genre name cannot contain numbers")
            return
        }
        
        if genreExists(genreName) {
            showAlert(title: "Error", message: "genre '\(genreName)' already exists.")
            return
        }
        do{
            dataManager.updateGenre(genre: genre!, newName: genreNameTextField.text!)
            showAlert(title: "Success", message: "Update Success!")
            delegate?.genreDidUpdate()
        } catch {
                showAlert(title: "Error", message: "Failed to update genre: \(error.localizedDescription)")
            }
        }
    
    private func containsDigits(_ string: String) -> Bool {
        let range = string.rangeOfCharacter(from: .decimalDigits)
        return range != nil
    }
    
    private func genreExists(_ name: String) -> Bool {
        return dataManager.genresModel.contains { $0.name?.lowercased() == name.lowercased() }
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
