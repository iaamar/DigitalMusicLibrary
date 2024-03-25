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


class ArtistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, ArtistUpdateDelegate {
    func artistDidUpdate() {
        retrieveData()
    }
    
    var artists = [Artist]()
    var filteredArtists = [Artist]()
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
    
    @IBAction func onAddButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addArtist", sender: self)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // showArtistDetails(at: indexPath.row)
        performSegue(withIdentifier: "viewArtist", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataManager.deleteArtist(artist: dataManager.artistsModel[indexPath.row])
            retrieveData()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
                destinationVC.delegate = self // Assign delegate
            }
        }
    }
}

//class ArtistDetailsViewController: UIViewController, ArtistUpdateDelegate {
//    func artistDidUpdate() {
//        delegate?.artistDidUpdate()
//    }
//    
//    var dataManager = DataStore.shared
//
//    @IBOutlet weak var imageView: UIImageView!
//    
//    @IBOutlet weak var artistNameLabel: UILabel!
//    
//    var artist: Artist?
//    
//    weak var delegate: ArtistUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        delegate?.artistDidUpdate()
//        if let artist = artist {
//            artistNameLabel.text = artist.name
//            let randomIndex =  Int.random(in: 1...8)
//            let imageName = "artist\(randomIndex)"
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
//        performSegue(withIdentifier: "editArtist", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "editArtist" {
//            if let editArtistVC = segue.destination as? EditArtistViewController {
//                editArtistVC.delegate = self
//                editArtistVC.artist = artist
//            }
//        }
//    }
//    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
//        if let artist = artist {
//
//            let isArtistUsed = dataManager.albumsModel.contains(where: { $0.artistId == artist.id })
//            if isArtistUsed {
//                showAlert(title: "Error", message: "Selected artist is associated with one or more album and cannot be deleted")
//                return
//            }
//            do {
//                dataManager.deleteArtist(artist: artist)
//                showAlert(title: "Success", message: "Artist Deleted!")
//                delegate?.artistDidUpdate() // Call delegate method after deleting artist
//            } catch {
//                showAlert(title: "Error", message: "Failed to delete artist: \(error.localizedDescription)")
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


//class AddArtistViewController: UIViewController, ArtistUpdateDelegate {
//    func artistDidUpdate() {
//        delegate?.artistDidUpdate()
//    }
//    
//    @IBOutlet weak var artistNameTextField: UITextField!
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    @IBOutlet weak var backButton: UIButton!
//    weak var delegate: ArtistUpdateDelegate?
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
//        delegate?.artistDidUpdate()
//    }
//    
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        guard let artistName = artistNameTextField.text, !artistName.isEmpty else {
//            showAlert(title: "Error", message: "Artist name cannot be empty")
//            return
//        }
//        
//        if containsDigits(artistName) {
//            showAlert(title: "Error", message: "Artist name cannot contain numbers")
//            return
//        }
//        
//        if artistExists(artistName) {
//            showAlert(title: "Error", message: "Artist '\(artistName)' already exists.")
//            return
//        }
//        createArtist(name: artistName)
//        artistNameTextField.text = ""
//        delegate?.artistDidUpdate()
//    }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func artistExists(_ name: String) -> Bool {
//        return dataManager.artistsModel.contains { $0.name?.lowercased() == name.lowercased() }
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
//    func createArtist(name: String) {
//        let newArtist = Artist(context: managedObjectContext)
//        newArtist.name = name
//        newArtist.id = UUID()
//        newArtist.albums = []
//        
//        do {
//            try managedObjectContext.save()
//            showAlert(title: "Success", message: "Artist added!!")
//        } catch {
//            print("Failed to create artist: \(error.localizedDescription)")
//        }
//    }
//    
//    @IBAction func backPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//
//}

//
//class EditArtistViewController: UIViewController {
//    var artist: Artist?
//    @IBOutlet weak var artistNameTextField: UITextField!
//    var dataManager = DataStore.shared
//    var managedObjectContext: NSManagedObjectContext!
//    @IBOutlet weak var backButton: UIButton!
//    weak var delegate: ArtistUpdateDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("AppDelegate not found")
//        }
//        managedObjectContext = appDelegate.persistentContainer.viewContext
//        artistNameTextField.text = artist?.name
//    }
//    
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        guard let artistName = artistNameTextField.text, !artistName.isEmpty else {
//            showAlert(title: "Error", message: "Artist name cannot be empty")
//            return
//        }
//        
//        if containsDigits(artistName) {
//            showAlert(title: "Error", message: "Artist name cannot contain numbers")
//            return
//        }
//        
//        if artistExists(artistName) {
//            showAlert(title: "Error", message: "Artist '\(artistName)' already exists.")
//            return
//        }
//        do{
//            dataManager.updateArtist(artist: artist!, newName: artistNameTextField.text!)
//            showAlert(title: "Success", message: "Update Success!")
//            delegate?.artistDidUpdate()
//        } catch {
//                showAlert(title: "Error", message: "Failed to update artist: \(error.localizedDescription)")
//            }
//        }
//    
//    private func containsDigits(_ string: String) -> Bool {
//        let range = string.rangeOfCharacter(from: .decimalDigits)
//        return range != nil
//    }
//    
//    private func artistExists(_ name: String) -> Bool {
//        return dataManager.artistsModel.contains { $0.name?.lowercased() == name.lowercased() }
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
