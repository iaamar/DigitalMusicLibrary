//
//  AddGenresViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData

class AddGenreViewController: UIViewController, GenreUpdateDelegate {
    func genreDidUpdate() {
        delegate?.genreDidUpdate()
    }
    
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
        delegate?.genreDidUpdate()
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
        createGenre(name: genreName)
        genreNameTextField.text = ""
        delegate?.genreDidUpdate()
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
    
    func createGenre(name: String) {
        let newGenre = Genres(context: managedObjectContext)
        newGenre.name = name
        newGenre.id = UUID()
        
        do {
            try managedObjectContext.save()
            showAlert(title: "Success", message: "Genre added!!")
        } catch {
            print("Failed to create genre: \(error.localizedDescription)")
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
