//
//  ViewController.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/4/24.
//

import UIKit



class ViewController: UIViewController {
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .dark
        toolbar.barTintColor = .black
    }
    
    @IBAction func onArtistClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "artistViewController", sender: self)
    }
    
    @IBAction func onAlbumsClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "albumsViewController", sender: self)
    }
    
    @IBAction func onSongsClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "songsViewController", sender: self)
    }
    
    @IBAction func onGenresClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "genresViewController", sender: self)
    }
}
