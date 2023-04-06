//
//  FilmRollViewController.swift
//  Exposed
//
//  Created by Melissa Rimsza on 10/27/22.
//

//THIS CLASS IS FUCKED

import Foundation
import UIKit
import SwiftPhotoGallery

class FilmRollViewController : UIViewController, SwiftPhotoGalleryDelegate, SwiftPhotoGalleryDataSource {
    
    
    @IBOutlet var thisCollectionView: UICollectionView!
    
    //@IBOutlet var scrollView: UIScrollView!
    
    //getting a filmRollManager to work with !!!!!!!!!!!
    var rollManager = FilmRollManager()

    var thisRoll : FilmRoll!
    
    let frameWidth = UIScreen.main.bounds.width
    let frameHeight = UIScreen.main.bounds.height
    
    let endingY = 0
    
    //pod stuff
    var gallery: SwiftPhotoGallery!
    
    let imageNames = ["newIcon.png", "TakePhoto.png", "filmRoll.png", "Main.png", "backArrow.png"]
    //var imageNames : [String] = []
    var imageNameArray : [String] = []
    var index: Int = 0
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        self.index = gallery.currentPage
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return imageNames.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return UIImage(named: imageNames[forIndex])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("FILM ROLL VIEW CONTROLLER")
        
        rollManager.load()
        
        thisRoll = rollManager.giveMeRoll(thisOne: selectedRoll)
        
        print("printing thisRoll: ")
        print(thisRoll)
        
        //addToArray()
        
        /*
        //setting up scroll view
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 2
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        //scrollView.backgroundColor = .white*/
        
        //pod stuff
        gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        
        let frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        gallery.view.frame = frame
        gallery.backgroundColor = UIColor.white
        view.addSubview(gallery.view)
        gallery.didMove(toParent: self)
        /*
        gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        let frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        
        gallery.view.frame = frame
        view.addSubview(gallery.view)
        gallery.didMove(toParent: self)*/
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("HERE")
        
        //scrollView.backgroundColor = .white
        presentContent()
        present(gallery, animated: true, completion: nil)
        
    }
    
    @objc func backArrowTapped(_ sender:UIButton) {
        print("print back arrow tapped")
        let filmLibraryView = self.storyboard?.instantiateViewController(withIdentifier: "FilmLibraryVC") as! FilmLibraryViewController
        self.navigationController?.pushViewController(filmLibraryView, animated: true)
    }
    
    func presentContent() {
        print("I am here!")
        presentUIButtons()
        presentFilmStrips()
    }
    
    func presentUIButtons() {
        //back button
        let image = UIImage(named: "backArrow.png")
        let backButton = UIButton()
        backButton.frame = CGRect(x: 10, y: 10, width: 45, height: 30)
        backButton.setBackgroundImage(image, for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backArrowTapped(_:)), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    func presentFilmStrips() {
        print("presentFilmStrips called!")
        let imageName = "filmStripVerticle.png"
        let image = UIImage(named: imageName)
        let leftStrip = UIImageView(image: image!)
        leftStrip.frame = CGRect(x: 0, y: 125, width: 100, height: 1375)
        //scrollView.addSubview(leftStrip)
        view.addSubview(leftStrip)
        
        let rightStrip = UIImageView(image: image!)
        rightStrip.frame = CGRect(x: frameWidth - 100, y: 125, width: 100, height: 1375)
        //scrollView.addSubview(rightStrip)
        view.addSubview(rightStrip)
    }
    

    
    func readImages() {
        
        //read and print image names
        let fileManager = FileManager.default
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathString = path.path

        //checking user documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("User documents directory: ")
        print(documentsDirectory)
        print(" ")
        
        let items = try! fileManager.contentsOfDirectory(atPath: pathString)

        for item in items {
            print("I found an item: ")
            print(item)
            print(" ")
            
            //adding images to the image array and printing image names
            if item.hasSuffix(".jpg") {
                print("I found an item: ")
                print(item)
                print(" ")
                
                imageNameArray.append(item)
            }
            
        }
    }
    
}




