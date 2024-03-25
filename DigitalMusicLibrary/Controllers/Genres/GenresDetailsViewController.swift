//
//  GenresDetailsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/24/24.
//

import Foundation
import UIKit
import CoreData

class GenreDetailsViewController: UIViewController, GenreUpdateDelegate {
    func genreDidUpdate() {
        delegate?.genreDidUpdate()
    }
    
    var dataManager = DataStore.shared
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var genreNameLabel: UILabel!
    
    var genre: Genres?
    
    weak var delegate: GenreUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.genreDidUpdate()
        if let genre = genre {
            genreNameLabel.text = genre.name
            let randomIndex =  Int.random(in: 1...8)
            let imageName = "genre\(randomIndex)"
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
        performSegue(withIdentifier: "editGenre", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editGenre" {
            if let editGenreVC = segue.destination as? EditGenreViewController {
                editGenreVC.delegate = self
                editGenreVC.genre = genre
            }
        }
    }
    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
        if let genre = genre {
            // Check if the genre exists
            guard let existingGenreIndex = dataManager.genresModel.firstIndex(where: { $0.id == genre.id }) else {
                showAlert(title: "Error", message: "Selected genre does not exist")
                return
            }
            let isGenreUsed = dataManager.albumsModel.contains(where: { $0.id == genre.id })
            if isGenreUsed {
                showAlert(title: "Error", message: "Selected genre is associated with one or more album and cannot be deleted")
                return
            }
            do {
                dataManager.deleteGenre(genre: genre)
                showAlert(title: "Success", message: "Genre Deleted!")
                delegate?.genreDidUpdate()
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

