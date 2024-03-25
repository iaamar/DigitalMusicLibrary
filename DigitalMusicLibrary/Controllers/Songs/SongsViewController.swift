//
//  SongsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/5/24.
//

import Foundation
import UIKit
import CoreData

protocol SongUpdateDelegate: AnyObject {
    func songDidUpdate()
}

class SongsViewController: UITableViewController, UISearchBarDelegate, SongUpdateDelegate {
    
    func songDidUpdate() {
        retrieveData()
    }
    
    var songs: [Songs] = []
    var albums: [Albums] = []
    var artists: [Artist] = []
    var genres: [Genres] = []
    var filteredSongs: [Songs] = []
    var dataManager = DataStore.shared
    var managedObjectContext: NSManagedObjectContext!
    //    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let nib = UINib(nibName: "TableCell", bundle: nil)
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
        performSegue(withIdentifier: "addSong", sender: self)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredSongs = songs
        } else {
            filteredSongs = songs.filter {
                if let name = $0.title?.lowercased(), name.contains(searchText.lowercased()){
                    return true
                }
                return false
            }
        }
        if filteredSongs.isEmpty{
            showAlert(title: "Not Found", message: "The searched song is not present.")
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
        dataManager.getAllSongs()
        self.songs = dataManager.songsModel
        self.albums = dataManager.albumsModel
        self.songs = dataManager.songsModel
        self.artists = dataManager.artistsModel
        self.genres = dataManager.genresModel
        self.filteredSongs = self.songs
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCellView", for: indexPath)
        cell.textLabel?.text = filteredSongs[indexPath.row].title
        
        let randomIndex =  Int.random(in: 1...8)
        
        let imageName = "song\(randomIndex)"
        let image = UIImage(named: imageName)
        if image == UIImage(named: imageName) {
        } else {
            cell.imageView?.image = UIImage(named: "defaultImage")
        }
        cell.imageView?.image = image
        cell.imageView?.layer.cornerRadius = 15
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewSong", sender: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataManager.deleteSong(song: dataManager.songsModel[indexPath.row])
            retrieveData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSong" {
            if let addSongVC = segue.destination as? AddSongViewController {
                addSongVC.delegate = self
            }
        } else if segue.identifier == "viewSong" {
            if let index = sender as? Int,
               let destinationVC = segue.destination as? SongDetailsViewController {
                destinationVC.song = dataManager.songsModel[index]
                destinationVC.delegate = self // Assign delegate
                destinationVC.artists = artists
                destinationVC.albums = albums
                destinationVC.genres = genres
            }
        }
    }
}
