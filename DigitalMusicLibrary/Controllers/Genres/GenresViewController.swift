//
//  GenresViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/5/24.
//

import Foundation
import UIKit
import CoreData

protocol GenreUpdateDelegate: AnyObject {
    func genreDidUpdate()
}
class GenresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GenreUpdateDelegate {
    func genreDidUpdate() {
        retrieveData()
    }

    var genres: [Genres] = []
    var filteredGenres: [Genres] = []
    var managedObjectContext: NSManagedObjectContext!
    var dataManager = DataStore.shared
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "customCellView")
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.barTintColor = .black
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        retrieveData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredGenres = genres
        } else {
            filteredGenres = genres.filter {
                if let name = $0.name?.lowercased(), name.contains(searchText.lowercased()){
                    return true
                }
                return false
            }
        }
        if filteredGenres.isEmpty{
            showAlert(title: "Not Found", message: "The searched genre is not present.")
        }
        tableView.reloadData()
    }
    
    @IBAction func onAddButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addGenre", sender: self)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func retrieveData() {
        dataManager.getAllGenres()
        self.genres = dataManager.genresModel
        self.filteredGenres = self.genres
        tableView.reloadData()
    }
    
    // Implement UITableViewDelegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGenres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCellView", for: indexPath)
        cell.textLabel?.text = filteredGenres[indexPath.row].name
        
        let randomIndex =  Int.random(in: 1...8)
        
        let imageName = "genre\(randomIndex)"
        if let image = UIImage(named: imageName) {
            cell.imageView?.image = image
            cell.imageView?.layer.cornerRadius = 15
            cell.imageView?.clipsToBounds = true
        } else {
            cell.imageView?.image = UIImage(named: "defaultImage")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewGenre", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addGenre" {
            if let addGenreVC = segue.destination as? AddGenreViewController {
                addGenreVC.delegate = self
            }
        } else if segue.identifier == "viewGenre" {
            if let index = sender as? Int,
               let destinationVC = segue.destination as? GenreDetailsViewController {
                destinationVC.genre = dataManager.genresModel[index]
                destinationVC.delegate = self // Assign delegate
            }
        }
    }
    
    @IBAction func onBackButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

//
//class GenreDetailsViewController: UIViewController, GenreUpdateDelegate {
//    func genreDidUpdate() {        
//        delegate?.genreDidUpdate()
//    }
//    
//    var dataManager = DataStore.shared
//    @IBOutlet weak var imageView: UIImageView!
//    
//    @IBOutlet weak var genreNameLabel: UILabel!
//    
//    var genre: Genres?
//    
//    weak var delegate: GenreUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        delegate?.genreDidUpdate()
//        if let genre = genre {
//            genreNameLabel.text = genre.name
//            let randomIndex =  Int.random(in: 1...8)
//            let imageName = "genre\(randomIndex)"
//            if let image = UIImage(named: imageName){
//                imageView.image = image
//                imageView.layer.cornerRadius = 15
//                imageView.clipsToBounds = true
//                imageView.layer.shadowColor = UIColor.black.cgColor
//                imageView.layer.shadowOpacity = 0.5
//                imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
//                imageView.layer.shadowRadius = 4
//                imageView.layer.masksToBounds = false
//            } else {
//                imageView.image = UIImage(named: "defaultImage")
//            }
//        }
//        
//    }
//    
//    @IBAction func onEditButtonPressed(_ sender: UIButton) {
//        performSegue(withIdentifier: "editGenre", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "editGenre" {
//            if let editGenreVC = segue.destination as? EditGenreViewController {
//                editGenreVC.delegate = self
//                editGenreVC.genre = genre
//            }
//        }
//    }
//    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
//        if let genre = genre {
//            // Check if the genre exists
//            guard let existingGenreIndex = dataManager.genresModel.firstIndex(where: { $0.id == genre.id }) else {
//                showAlert(title: "Error", message: "Selected genre does not exist")
//                return
//            }
//            let isGenreUsed = dataManager.albumsModel.contains(where: { $0.id == genre.id })
//            if isGenreUsed {
//                showAlert(title: "Error", message: "Selected genre is associated with one or more album and cannot be deleted")
//                return
//            }
//            do {
//                dataManager.deleteGenre(genre: genre)
//                showAlert(title: "Success", message: "Genre Deleted!")
//                delegate?.genreDidUpdate()
//            } catch {
//                showAlert(title: "Error", message: "Failed to delete genre: \(error.localizedDescription)")
//            }
//        }
//       
//    }
//    
//    private func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
//    @IBAction func backButtonPRessed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    
//}

//
//class AddGenreViewController: UIViewController, GenreUpdateDelegate {
//    func genreDidUpdate() {
//        delegate?.genreDidUpdate()
//    }
//    
//    @IBOutlet weak var genreNameTextField: UITextField!
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    @IBOutlet weak var backButton: UIButton!
//    weak var delegate: GenreUpdateDelegate?
//
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("AppDelegate not found")
//        }
//        managedObjectContext = appDelegate.persistentContainer.viewContext
//        delegate?.genreDidUpdate()
//    }
//    
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        guard let genreName = genreNameTextField.text, !genreName.isEmpty else {
//            showAlert(title: "Error", message: "genre name cannot be empty")
//            return
//        }
//        
//        if containsDigits(genreName) {
//            showAlert(title: "Error", message: "genre name cannot contain numbers")
//            return
//        }
//        
//        if genreExists(genreName) {
//            showAlert(title: "Error", message: "genre '\(genreName)' already exists.")
//            return
//        }
//        createGenre(name: genreName)
//        genreNameTextField.text = ""
//        delegate?.genreDidUpdate()
//    }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func genreExists(_ name: String) -> Bool {
//        return dataManager.genresModel.contains { $0.name?.lowercased() == name.lowercased() }
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    
//    private func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
//    
//    func createGenre(name: String) {
//        let newGenre = Genres(context: managedObjectContext)
//        newGenre.name = name
//        newGenre.id = UUID()
//        
//        do {
//            try managedObjectContext.save()
//            showAlert(title: "Success", message: "Genre added!!")
//        } catch {
//            print("Failed to create genre: \(error.localizedDescription)")
//        }
//    }
//    
//    @IBAction func backPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//
//}

//
//class EditGenreViewController: UIViewController {
//    var genre: Genres?
//    @IBOutlet weak var genreNameTextField: UITextField!
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    @IBOutlet weak var backButton: UIButton!
//    weak var delegate: GenreUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("AppDelegate not found")
//        }
//        managedObjectContext = appDelegate.persistentContainer.viewContext
//        genreNameTextField.text = genre?.name
//    }
//    
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        guard let genreName = genreNameTextField.text, !genreName.isEmpty else {
//            showAlert(title: "Error", message: "genre name cannot be empty")
//            return
//        }
//        
//        if containsDigits(genreName) {
//            showAlert(title: "Error", message: "genre name cannot contain numbers")
//            return
//        }
//        
//        if genreExists(genreName) {
//            showAlert(title: "Error", message: "genre '\(genreName)' already exists.")
//            return
//        }
//        do{
//            dataManager.updateGenre(genre: genre!, newName: genreNameTextField.text!)
//            showAlert(title: "Success", message: "Update Success!")
//            delegate?.genreDidUpdate()
//        } catch {
//                showAlert(title: "Error", message: "Failed to update genre: \(error.localizedDescription)")
//            }
//        }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func genreExists(_ name: String) -> Bool {
//        return dataManager.genresModel.contains { $0.name?.lowercased() == name.lowercased() }
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//    
//    private func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
//
//    @IBAction func backButtonPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//}
