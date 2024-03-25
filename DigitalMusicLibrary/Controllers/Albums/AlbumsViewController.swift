//
//  AlbumsViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/5/24.
//

import Foundation
import UIKit
import CoreData

protocol AlbumUpdateDelegate: AnyObject {
    func albumDidUpdate()
}

class AlbumsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AlbumUpdateDelegate {
 
    func albumDidUpdate() {
        retrieveData()
    }
    
    var albums: [Albums] = []
    var songs: [Songs] = []
    var artists: [Artist] = []
    var genres: [Genres] = []
    var filteredAlbums: [Albums] = []
    var dataManager = DataStore.shared
    var managedObjectContext: NSManagedObjectContext!
    
    
    @IBOutlet weak var albumSearchBar: UISearchBar!
    
    
    @IBOutlet weak var albumTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TableCell", bundle: nil)
        albumTableView.register(nib, forCellReuseIdentifier: "customCellView")
        albumTableView.delegate = self
        albumTableView.dataSource = self
        albumSearchBar.delegate = self
        albumSearchBar.barTintColor = .black
        albumTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        retrieveData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredAlbums = albums
        } else {
            filteredAlbums = albums.filter {
                if let name = $0.title?.lowercased(), name.contains(searchText.lowercased()){
                    return true
                }
                return false
            }
        }
        if filteredAlbums.isEmpty{
            showAlert(title: "Not Found", message: "The searched album is not present.")
        }
        
        albumTableView.reloadData()
    }
 
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    
    func retrieveData() {
        dataManager.getAllAlbums()
        self.albums = dataManager.albumsModel
        self.songs = dataManager.songsModel
        self.artists = dataManager.artistsModel
        self.genres = dataManager.genresModel
        self.filteredAlbums = self.albums
        albumTableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addAlbum", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCellView", for: indexPath)
        cell.textLabel?.text = filteredAlbums[indexPath.row].title
        
        let randomIndex =  Int.random(in: 1...8)

        let imageName = "album\(randomIndex)"
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewAlbum", sender: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataManager.deleteAlbum(album: dataManager.albumsModel[indexPath.row])
            retrieveData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addAlbum" {
            if let addAlbumVC = segue.destination as? AddAlbumViewController {
                addAlbumVC.delegate = self
            }
        } else if segue.identifier == "viewAlbum" {
            if let index = sender as? Int,
               let destinationVC = segue.destination as? AlbumDetailsViewController {
                destinationVC.album = dataManager.albumsModel[index]
                destinationVC.delegate = self // Assign delegate
                destinationVC.artists = artists
                destinationVC.albums = albums
                destinationVC.genres = genres
            }
        }
    }
}
//
//class AlbumDetailsViewController: UIViewController, AlbumUpdateDelegate {
//
//    func albumDidUpdate() {
//        delegate?.albumDidUpdate()
//    }
//
//    var dataManager = DataStore.shared
//    
//    var albums: [Albums] = []
//    var songs: [Songs] = []
//    var artists: [Artist] = []
//    var genres: [Genres] = []
//    
//    @IBOutlet weak var albumtitleLabel: UILabel!
//    
//    @IBOutlet weak var aritistIdLabel: UILabel!
//    
//    @IBOutlet weak var relaseDateLabel: UILabel!
//    
//    @IBOutlet weak var songListLabel: UILabel!
//    
//    @IBOutlet weak var albumImageView: UIImageView!
//    
//    @IBOutlet weak var editButton: UIButton!
//    
//    @IBOutlet weak var deleteButton: UIButton!
//    
//    var album: Albums?
//    
//    weak var delegate: AlbumUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        delegate?.albumDidUpdate()
//        if let album = album {
//            let randomIndex =  Int.random(in: 1...8)
//            let imageName = "album\(randomIndex)"
//            if let image = UIImage(named: imageName){
//                albumImageView.image = image
//                albumImageView.layer.cornerRadius = 15
//                albumImageView.clipsToBounds = true
//                albumImageView.layer.shadowColor = UIColor.black.cgColor
//                albumImageView.layer.shadowOpacity = 0.5
//                albumImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
//                albumImageView.layer.shadowRadius = 4
//                albumImageView.layer.masksToBounds = false
//            } else {
//                albumImageView.image = UIImage(named: "defaultImage")
//            }
//        }
//        albumtitleLabel.text = "Album: " + (album?.title)!
//        aritistIdLabel.text = "Artist: " + getArtistName(for: (album?.artistId)!)
//        relaseDateLabel.text = "Release Date: " + (album?.releaseDate)!
//        songListLabel.text = "Song's: " + getSongsList(for: (album?.id)!)
//    }
//    
//    func getSongsList(for albumID: UUID) -> String {
//        let songsInAlbum = dataManager.songsModel.filter { $0.albumId == albumID }
//        let albumNames = songsInAlbum.map { $0.title ?? "" }
//        return albumNames.isEmpty ? "No songs associated" : albumNames.joined(separator: ", ")
//    }
//    func getArtistName(for artistId: UUID) -> String {
//        guard let artist = artists.first(where: { $0.id == artistId }) else {
//            return "\(artistId)"
//        }
//        return artist.name ?? "\(artistId)"
//    }
//    
//    func getAlbumTitle(for albumId: UUID) -> String {
//        guard let album = albums.first(where: { $0.id == albumId }) else {
//            return "\(albumId)"
//        }
//        return album.title ?? "\(albumId)"
//    }
//
//    @IBAction func onEditButtonPressed(_ sender: UIButton) {
//        performSegue(withIdentifier: "editAlbum", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "editAlbum" {
//            if let editAlbumVC = segue.destination as? EditAlbumViewController {
//                editAlbumVC.delegate = self
//                editAlbumVC.album = album
//            }
//        }
//    }
//    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
//        if let album = album {
//            let associatedSongs = dataManager.songsModel.filter { $0.albumId == album.id }
//            if !associatedSongs.isEmpty {
//                showAlert(title: "Error", message: "Selected album is associated with one or more songs and cannot be deleted")
//                return
//            } else {
//                do {
//                    dataManager.deleteAlbum(album: album)
//                    showAlert(title: "Success", message: "Album Deleted!")
//                    delegate?.albumDidUpdate()
//                } catch {
//                    showAlert(title: "Error", message: "Failed to delete album: \(error.localizedDescription)")
//                }
//            }
//        }
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
//}
//
//
//class AddAlbumViewController: UIViewController, AlbumUpdateDelegate {
//
//    func albumDidUpdate() {
//        delegate?.albumDidUpdate()
//    }
//    
//    @IBOutlet weak var albumNameTextField: UITextField!
// 
//
//    @IBOutlet weak var artistIdField: UITextField!
//    
//   
//    @IBOutlet weak var releaseDate: UIDatePicker!
//    
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    weak var delegate: AlbumUpdateDelegate?
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
//        delegate?.albumDidUpdate()
//    }
//    
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        
//        let artistId = Int(artistIdField.text!)!
//       
//        if albumExists(albumNameTextField.text!) {
//            showAlert(title: "Error", message: "album '\(String(describing: albumNameTextField.text))' already exists.")
//            return
//        }
//        guard dataManager.artistsModel.first(where: { $0.id == dataManager.artistsModel[artistId-1].id }) != nil else {
//            showAlert(title: "Error", message: "Artist with ID \(artistIdField.text) does not exist")
//            return
//        }
//    
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//
//        let releaseDateString = dateFormatter.string(from: releaseDate.date)
//        addAlbum(title: albumNameTextField.text!, artistIndex: artistId, releaseDate: releaseDateString)
//        
//    }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func albumExists(_ title: String) -> Bool {
//        return dataManager.albumsModel.contains { $0.title?.lowercased() == title.lowercased() }
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
//        }
//    
//    // Function to add a new album
//    func addAlbum(title: String, artistIndex: Int, releaseDate: String) {
//        // Validate input
//        guard !title.isEmpty else
//        {
//            showAlert(title: "Error", message: "Title cannot be empty")
//            return
//        }
//        guard dataManager.artistsModel.count >= artistIndex else{
//            showAlert(title: "Error", message: "Artist does not exist with index \(artistIndex)")
//            return
//        }
//        let actualIndex = artistIndex - 1
// 
//        guard !releaseDate.isEmpty else {
//            showAlert(title: "Error", message: "Release date cannot be empty")
//            return
//        }
//        do{
//            dataManager.addAlbum(albumtitle: title, releaseDate: releaseDate, artistId: dataManager.artistsModel[actualIndex].id!)
//            showAlert(title: "Success", message: "Album Created!")
//            delegate?.albumDidUpdate()
//        }catch{
//            showAlert(title: "Error", message: "Failed to add album: \(error.localizedDescription)")
//        }
//        
//    }
//    
//    @IBAction func onBackPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
// 
//}
//

//
//class EditAlbumViewController: UIViewController {
//    var album: Albums?
//    
//    @IBOutlet weak var albumTitle: UITextField!
//    
//    @IBOutlet weak var releaseDatePicker: UIDatePicker!
//    
//    
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    weak var delegate: AlbumUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("AppDelegate not found")
//        }
//        managedObjectContext = appDelegate.persistentContainer.viewContext
//        albumTitle.text = album?.title
//        
//    }
//    
//    
// func updateAlbum(album: Albums, title: String, releaseDate: String) {
//    
//    // Validate input
//    guard !title.isEmpty else {
//        showAlert(title: "Error", message: "Album title cannot be empty")
//        return
//    }
//    
//     guard !releaseDatePicker.date.description.isEmpty else {
//        showAlert(title: "Error", message: "Release date cannot be empty")
//        return
//    }
//    dataManager.updateAlbum(albumtitle: title, releaseDate: releaseDate, updatedAlbum: album)
//}
//
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd-MM-yyyy"
//
//        let releaseDateString = dateFormatter.string(from: releaseDatePicker.date)
//        do{
//            updateAlbum(album: album!, title: albumTitle.text!, releaseDate: releaseDateString)
//            showAlert(title: "Success", message: "Update Success!")
//            delegate?.albumDidUpdate()
//        } catch {
//                showAlert(title: "Error", message: "Failed to update albums: \(error.localizedDescription)")
//            }
//        }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func albumsExists(_ name: String) -> Bool {
//        return dataManager.albumsModel.contains { $0.title?.lowercased() == name.lowercased() }
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
//
