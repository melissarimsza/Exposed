//
//  MainCollectionViewController.swift
//  Exposed
//
//  Created by Melissa Rimsza on 12/18/22.
//


//WORKING ON GETTING THE CORRECT PHOTOS FROM THE ROLL 

import Foundation
import UIKit
import SwiftPhotoGallery

private let reuseIdentifier = "Cell"

class MainCollectionViewController: UICollectionViewController {
    
    let frameWidth = UIScreen.main.bounds.width
    let frameHeight = UIScreen.main.bounds.height
    
    //for the override function to know whether or not to display the photos
    var displayPhotos: Bool = true
    
    //getting a filmRollManager to work with !!!!!!!!!!!
    var rollManager = FilmRollManager()

    var thisRoll : FilmRoll!
    var gallery: SwiftPhotoGallery!
    var imageNames : [String] = []
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rollManager.load()
        
        print("selected roll number: ")
        print(selectedRoll)
        thisRoll = rollManager.giveMeRoll(thisOne: selectedRoll)
        print("checking here:")
        print(thisRoll.takenDate)
        
        print("printing this roll count")
        print(thisRoll.photos.count)
        
        //nav view customization
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 1, alpha: 0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(white: 1, alpha: 0)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        collectionView.backgroundColor = UIColor.white
        checkPhotoAvailability()
        
        /*
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let pathname = documentsDirectory!.appendingPathComponent("photo_2023-02-23_11-17-19-52.jpg")
        
        do {
            let imageData = try Data(contentsOf: pathname)
            let saveImage = UIImage(data: imageData)
            UIImageWriteToSavedPhotosAlbum(saveImage!, nil, nil, nil)
        } catch {
            print("fuck its in the catch")
            print("Error loading image : \(error)")
        }
        
        print("printing all the names of the photos in this roll")
        for i in stride(from: 0, to: thisRoll.names.count, by: 1) {
            print (thisRoll.names[i])
        }*/

        //THIS IS BEING USED DOWN BELOW WHEN CREATING THE GALLERY
        for i in stride(from: 0, to: thisRoll.names.count, by: 1) {
            imageNames.append(thisRoll.names[i])
        }
        
    }
    
    
    func checkPhotoAvailability() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let timestamp = formatter.string(from: now)
        
        print("printing time stamp: ")
        print(timestamp)
        
        print("printing title: ")
        print(thisRoll.takenDate)
        
        if (thisRoll.takenDate == timestamp) {
            displayPhotos = false
        }
        else {
            displayPhotos = true
        }
    }
    

    // MARK: UICollectionViewDataSource
    //setting the number of photo sections, will always be one
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    //getting the total number of photos
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return imageNames.count
        return thisRoll.photos.count
    }

    //displaying cell previews
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        
        if displayPhotos == true {
            print("display photos is true")
            
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            var pathname = documentsDirectory!.appendingPathComponent(imageNames[indexPath.item])
            
            /*
            do {
                let imageData = try Data(contentsOf: pathname)
                let saveImage = UIImage(data: imageData)
                UIImageWriteToSavedPhotosAlbum(saveImage!, nil, nil, nil)            }
            catch {
                print(error.localizedDescription)
            }*/
            
            //THIS IS THE LAST THING THAT IS NOT WORKING
            do {
                try cell.imageView.image = UIImage(contentsOfFile: pathname.path()) // String(contentsOf: pathname)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        else {
            let loadingImage = "photoDeveloping.png"
            cell.imageView.image = UIImage(named: loadingImage)
        }
        return cell
    }


    //present the specific image when clicked on from gallery view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("this method called")
        index = indexPath.item
        
        gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        
        let frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        gallery.view.frame = frame
        gallery.backgroundColor = UIColor.white
        gallery.currentPageIndicatorTintColor = UIColor.black
        view.addSubview(gallery.view)
        gallery.didMove(toParent: self)
        
        //present(gallery, animated: true, completion: nil)
        present(gallery, animated: true, completion: { () -> Void in
            print("present function called")
            self.gallery.currentPage = self.index
        })
    }
    
    //displaying the header and footer
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            
            headerView.backgroundColor = UIColor.white
            let imageName = "photos.png"
            let image = UIImage(named: imageName)
            let headerImage = UIImageView(image: image!)
            let thisWidth = Int(frameWidth) - 20
            let thisHeight = Int(thisWidth/4)
            headerImage.frame = CGRect(x: 10 , y: 50, width: thisWidth, height: thisHeight)
            headerView.addSubview(headerImage)

            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            
            let imageName = "filmStripRainbow.png"
            let image = UIImage(named: imageName)
            let footerImage = UIImageView(image: image!)
            footerImage.frame = CGRect(x: 0, y: 0, width: Int(frameWidth), height: 75)
            footerView.addSubview(footerImage)
            
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
}


// MARK: SwiftPhotoGalleryDataSource Methods
extension MainCollectionViewController: SwiftPhotoGalleryDataSource {

    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return thisRoll.photos.count
    }

    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        //save images when you scroll through
        if (displayPhotos == true) {
            print("I am here")
            print("index: ")
            print(forIndex)
            
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            var pathname = documentsDirectory!.appendingPathComponent(imageNames[forIndex])
            
            do {
                let imageData = try Data(contentsOf: pathname)
                let saveImage = UIImage(data: imageData)
                UIImageWriteToSavedPhotosAlbum(saveImage!, nil, nil, nil)
                return saveImage
            }
            catch {
                print(error.localizedDescription)
                return UIImage(named: "photoDeveloping.png")
            }
        }
        else {
            return UIImage(named: "photoDeveloping.png")
        }
    }
}


// MARK: SwiftPhotoGalleryDelegate Methods
extension MainCollectionViewController: SwiftPhotoGalleryDelegate {

    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        self.index = gallery.currentPage
        dismiss(animated: true, completion: nil)
    }
}


// MARK: UIViewControllerTransitioningDelegate Methods
extension MainCollectionViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let selectedCellFrame = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0))?.frame else { return nil }
        
        return PresentingAnimator(pageIndex: index, originFrame: selectedCellFrame)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let returnCellFrame = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0))?.frame else { return nil }
        return DismissingAnimator(pageIndex: index, finalFrame: returnCellFrame)
    }
}


