//
//  ArtistViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/5/24.
//

import Foundation
import UIKit
import CoreData


protocol ArtistUpdateDelegate: AnyObject {
    func artistDidUpdate()
}


class ArtistViewController: UITableViewController, UISearchBarDelegate, ArtistUpdateDelegate {
    
    func artistDidUpdate() {
        retrieveData()
    }
    
    var artists = [Artist]()
    var filteredArtists = [Artist]()
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
        searchBar.delegate = self
        searchBar.clipsToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        searchBar.barTintColor = .black
        // Initialize managed object context
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
        performSegue(withIdentifier: "addArtist", sender: self)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredArtists = artists
        } else {
            filteredArtists = artists.filter {
                if let name = $0.name?.lowercased(), name.contains(searchText.lowercased()){
                    return true
                }
                return false
            }
        }
        if filteredArtists.isEmpty{
            showAlert(title: "Not Found", message: "The searched artist is not present.")
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
        dataManager.getAllArtists()
        self.artists = dataManager.artistsModel
        self.filteredArtists = self.artists
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArtists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCellView", for: indexPath)
        cell.textLabel?.text = filteredArtists[indexPath.row].name
        
        let randomIndex =  Int.random(in: 1...8)
        
        let imageName = "artist\(randomIndex)"
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
        performSegue(withIdentifier: "viewArtist", sender: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataManager.deleteArtist(artist: dataManager.artistsModel[indexPath.row])
            retrieveData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addArtist" {
            if let addArtistVC = segue.destination as? AddArtistViewController {
                addArtistVC.delegate = self
            }
        } else if segue.identifier == "viewArtist" {
            if let index = sender as? Int,
               let destinationVC = segue.destination as? ArtistDetailsViewController {
                destinationVC.artist = dataManager.artistsModel[index]
            }
        }
    }
}
