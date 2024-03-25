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
class GenresViewController: UITableViewController, UISearchBarDelegate, GenreUpdateDelegate {
    func genreDidUpdate() {
        retrieveData()
    }
    
    var genres: [Genres] = []
    var filteredGenres: [Genres] = []
    var managedObjectContext: NSManagedObjectContext!
    var dataManager = DataStore.shared
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backPressed(_:)))
        navigationItem.leftBarButtonItem = backButton
        
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(plusPressed(_:)))
        navigationItem.rightBarButtonItem = plusButton
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "customCellView")
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
    @objc func backPressed(_ sender: UIBarButtonItem) {
        // Handle back button press here
        navigationController?.popViewController(animated: true)
        dismiss(animated: true,completion: nil)
    }
    @objc func plusPressed(_ sender: UIBarButtonItem) {
        // Handle back button press here
        performSegue(withIdentifier: "addGenre", sender: self)
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGenres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
}

