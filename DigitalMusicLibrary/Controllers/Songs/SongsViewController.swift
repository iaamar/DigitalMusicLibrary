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

class SongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SongUpdateDelegate {
 
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
    
    @IBAction func onAddButtonClicked(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "addSong", sender: self)
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
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
   
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewSong", sender: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
//
//class SongDetailsViewController: UIViewController, SongUpdateDelegate {
//
//    func songDidUpdate() {
//        delegate?.songDidUpdate()
//    }
//
//    var dataManager = DataStore.shared
//    
//    var songs: [Songs] = []
//    var albums: [Albums] = []
//    var artists: [Artist] = []
//    var genres: [Genres] = []
//    
//    @IBOutlet weak var songtitleLabel: UILabel!
//    
//    @IBOutlet weak var aritistIdLabel: UILabel!
//    
//    @IBOutlet weak var albumIdLabel: UILabel!
//    
//    @IBOutlet weak var genreIdLabel: UILabel!
//    
//    @IBOutlet weak var durationLabel: UILabel!
//    
//    @IBOutlet weak var favouriteLabel: UILabel!
//    
//    @IBOutlet weak var songImageView: UIImageView!
//    
//    @IBOutlet weak var editButton: UIButton!
//    
//    @IBOutlet weak var deleteButton: UIButton!
//    
//    var song: Songs?
//    
//    weak var delegate: SongUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        delegate?.songDidUpdate()
//        if let song = song {
//            songtitleLabel.text =  "Song Title: " + song.title!
//            aritistIdLabel.text = "Artist: " + getArtistName(for: song.artistId!)
//            albumIdLabel.text = "Album: " + getAlbumTitle(for: song.albumId!)
//            genreIdLabel.text = "Genre: " +  getGenreName(for: song.genreId!)
//            durationLabel.text = "Duration: " + String(song.duration)
//            favouriteLabel.text = "Is Favourite: " + String(song.isfavourite)
//            
//            let randomIndex =  Int.random(in: 1...8)
//            let imageName = "song\(randomIndex)"
//            if let image = UIImage(named: imageName){
//                songImageView.image = image
//                songImageView.layer.cornerRadius = 15
//                songImageView.clipsToBounds = true
//                songImageView.layer.shadowColor = UIColor.black.cgColor
//                songImageView.layer.shadowOpacity = 0.5
//                songImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
//                songImageView.layer.shadowRadius = 4
//                songImageView.layer.masksToBounds = false
//            } else {
//                songImageView.image = UIImage(named: "defaultImage")
//            }
//        }
//        
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
//    func getGenreName(for genreId: UUID) -> String {
//        guard let genre = dataManager.genresModel.first(where: { $0.id == genreId }) else {
//            return "\(genreId)"
//        }
//        return genre.name ?? ""
//    }
//    @IBAction func onEditButtonPressed(_ sender: UIButton) {
//        performSegue(withIdentifier: "editSong", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "editSong" {
//            if let editSongVC = segue.destination as? EditSongViewController {
//                editSongVC.delegate = self
//                editSongVC.song = song
//            }
//        }
//    }
//    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
//        if let song = song {
//            do {
//                dataManager.deleteSong(song: song)
//                showAlert(title: "Success", message: "Song Deleted!")
//                delegate?.songDidUpdate()
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
//}
//
//
//class AddSongViewController: UIViewController, SongUpdateDelegate {
//
//    func songDidUpdate() {
//        delegate?.songDidUpdate()
//    }
//    
//    @IBOutlet weak var songNameTextField: UITextField!
// 
//
//    @IBOutlet weak var artistIdField: UITextField!
//    
//    @IBOutlet weak var albumIdFiled: UITextField!
//    
//    @IBOutlet weak var genreIdField: UITextField!
//    
//    @IBOutlet weak var durationField: UITextField!
//    
//    @IBOutlet weak var favouriteField: UITextField!
//    
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    weak var delegate: SongUpdateDelegate?
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
//        delegate?.songDidUpdate()
//    }
//    
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        
//        let artistId = Int(artistIdField.text!)!
//        let albumId = Int(albumIdFiled.text!)!
//        let genreId = Int(genreIdField.text!)!
//        let duration = Double(durationField.text!)!
//        let isFavourite = Int(favouriteField.text!)!
//        if songExists(songNameTextField.text!) {
//            showAlert(title: "Error", message: "song '\(String(describing: songNameTextField.text))' already exists.")
//            return
//        }
//        addSong(title: songNameTextField.text!, artistId: artistId, albumId: albumId, genreId: genreId, duration: duration, isFavorite: isFavourite)
//        
//        
////        guard let songName = songNameTextField.text, !songName.isEmpty else {
////            showAlert(title: "Error", message: "song name cannot be empty")
////            return
////        }
////        
////        if containsDigits(songName) {
////            showAlert(title: "Error", message: "song name cannot contain numbers")
////            return
////        }
////        
////        if songExists(songName) {
////            showAlert(title: "Error", message: "song '\(songName)' already exists.")
////            return
////        }
////        let actualArtistId = artistIdField.text!
////        let artistIndex = Int(actualArtistId)! - 1
////        let actualAlbumId = albumIdFiled.text!
////        let albumIndex = Int(actualAlbumId)! - 1
////        let actualGenreId = genreIdField.text!
////        let genreIndex = Int(actualGenreId)! - 1
////        guard dataManager.artistsModel.first(where: { $0.id == dataManager.artistsModel[artistIndex].id }) != nil else {
////            showAlert(title: "Error", message: "Artist with ID \(artistIdField) does not exist")
////            return
////        }
////        
////        guard dataManager.albumsModel.first(where: { $0.id == dataManager.albumsModel[albumIndex].id }) != nil else {
////            showAlert(title: "Error", message: "Album with ID \(albumIdFiled) does not exist")
////            return
////        }
////        
////        guard dataManager.songsModel.first(where: { $0.id == dataManager.songsModel[genreIndex].id }) != nil else {
////            showAlert(title: "Error", message: "Genre with ID \(genreIdField) does not exist")
////            return
////        }
////        var isFav:Bool = false
////        if favouriteField.text == "1" {
////            isFav = true
////        }else{
////            isFav = false
////        }
////        guard case durationField.text = durationField.text, !durationField.text!.isEmpty else {
////            showAlert(title: "Error", message: "Song duration empty")
////            return
////        }
////        
////        if ((durationField.text?.isNumeric) != nil) {
////            if ((durationField.text?.isDouble) != nil) || ((durationField.text?.isInteger) != nil) {
////                if let doubleValue = Double(durationField.text!), !doubleValue.isNaN && !doubleValue.isZero{
////                    showAlert(title: "Error", message: "Song duration format incorrect or empty. Enter a integer or double value only")
////                    return
////                }
////            }
////        }
////        dataManager.addSong(title: songNameTextField.text, albumId: alb, genreId: <#T##UUID#>, artistId: <#T##UUID#>, duration: <#T##Double#>, isFav: <#T##Bool#>)
////        songNameTextField.text = ""
////        delegate?.songDidUpdate()
//    }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func songExists(_ title: String) -> Bool {
//        return dataManager.songsModel.contains { $0.title?.lowercased() == title.lowercased() }
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
//    // Function to add a new song
//    func addSong(title: String, artistId: Int, albumId: Int, genreId: Int, duration: Double, isFavorite: Int) {
//        // Validate input
//        guard !title.isEmpty else {
//            showAlert(title: "Error", message: "Song title cannot be empty")
//            return
//        }
//        
//        guard dataManager.artistsModel.first(where: { $0.id == dataManager.artistsModel[artistId - 1].id }) != nil else {
//            showAlert(title: "Error", message: "Artist with ID \(artistId) does not exist")
//            return
//        }
//        
//        guard dataManager.albumsModel.first(where: { $0.id == dataManager.albumsModel[albumId - 1].id }) != nil else {
//            showAlert(title: "Error", message: "Album with ID \(albumId) does not exist")
//            return
//        }
//        
//        guard dataManager.songsModel.first(where: { $0.id == dataManager.songsModel[genreId - 1].id }) != nil else {
//            showAlert(title: "Error", message: "Genre with ID \(genreId) does not exist")
//            return
//        }
//        do{
//            dataManager.addSong(title: title, albumId: dataManager.albumsModel[albumId - 1].id!, genreId: dataManager.songsModel[genreId - 1].id!, artistId: dataManager.artistsModel[artistId - 1].id!, duration: duration, isFav: (isFavorite != 0))
//        showAlert(title: "Success", message: "Song Added!!")
//            
//        } catch{
//                showAlert(title: "Error", message: "Failed to delete genre: \(error.localizedDescription)")
//            }
//    }
//
//    @IBAction func onBackPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
// 
//}


//
//
//class EditSongViewController: UIViewController {
//    var song: Songs?
//    
//    @IBOutlet weak var songTitle: UITextField!
//    
//    @IBOutlet weak var duration: UITextField!
//    
//    @IBOutlet weak var isFavourite: UITextField!
//    
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    weak var delegate: SongUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("AppDelegate not found")
//        }
//        managedObjectContext = appDelegate.persistentContainer.viewContext
//        songTitle.text = song?.title
//        duration.text = String(song!.duration)
//        var isFav = ""
//        if song?.isfavourite == true{
//            isFav = "1"
//        } else{
//            isFav = "0"
//        }
//        isFavourite.text = isFav
//    }
//    
//    
//    // Function to update an existing song
//    func updateSong(song: Songs, title: String, duration: Double, isFavorite: Int) {
//    
//        guard !title.isEmpty else {
//            showAlert(title: "Error", message: "Song title cannot be empty")
//            return
//        }
//        guard !duration.isNaN && !duration.isZero else{
//            showAlert(title: "Error", message: "Song duration format incorrect or empty")
//            return
//        }
//        var isSongFavorite = false
//        if isFavorite == 1 {
//            isSongFavorite = true
//        }else{
//            isSongFavorite = false
//        }
//        dataManager.updateSong(title: title, duration: duration, isFav: isSongFavorite, updatedSong: song)
//    }
//
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        
//        let duration = Double(duration.text!)!
//        var isSongFavorite = 0
//        if isFavourite.text == "1" {
//            isSongFavorite = 1
//        }else{
//            isSongFavorite = 0
//        }
//        do{
//            updateSong(song: song!, title: songTitle.text!, duration: duration, isFavorite: isSongFavorite)
//            showAlert(title: "Success", message: "Update Success!")
//            delegate?.songDidUpdate()
//        } catch {
//                showAlert(title: "Error", message: "Failed to update songs: \(error.localizedDescription)")
//            }
//        }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func songsExists(_ name: String) -> Bool {
//        return dataManager.songsModel.contains { $0.title?.lowercased() == name.lowercased() }
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
