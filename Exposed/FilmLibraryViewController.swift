//
//  FilmLibraryViewController.swift
//  Exposed
//
//  Created by Melissa Rimsza on 10/11/22.
//
//film roll struct with an array of file path names that lead to the images
//categorize at the time the photos are being taken
//the life of the indie developer

import Foundation
import UIKit

public var selectedRoll: Int = 0

class FilmLibraryViewController : UIViewController {
    
    let frameWidth = UIScreen.main.bounds.width
    let frameHeight = UIScreen.main.bounds.height
    
    //custom back button? - not working
    let yourBackImage = UIImage(named: "backImage")
    
    var filmRollButtonArray : [UIButton] = []
    
    //getting a filmRollManager to work with !!!!!!!!!!!
    var rollManager = FilmRollManager()
    
    //TEMP
    var imageNameArray: [String] = []
    
    var filmRollNameArray : [String] = []
    
    var filmRollLabelArray : [UITextField] = []
    
    var endingY = 0
    
    @IBOutlet var scrollView: UIScrollView!
    
    //@IBOutlet var textField: UITextField!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        print("FilmLibraryViewController viewDidLoad called")
        super.viewDidLoad()
        
        //setting up scroll view
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        scrollView.backgroundColor = .white

        
        //trying to hide nav bar
        //self.navigationController?.isNavigationBarHidden = true
        
        // For Back button customization, setup the custom image for UINavigationBar inside CustomBackButtonNavController.
        /*
        let backButtonBackgroundImage = UIImage(named: "backArrow.png")
        let barAppearance =
            UINavigationBar.appearance(whenContainedInInstancesOf: [FilmLibraryViewController.self])
        barAppearance.backIndicatorImage = backButtonBackgroundImage
        barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
        
        //remove text from back button
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton*/
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 1, alpha: 0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(white: 1, alpha: 0)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        //loading the info from the file, so now it should be in that filmRollArray
        rollManager.load()
        numRolls = rollManager.filmRollArray.count

        presentFilmRollLabels()
        presentFilmRolls()
        presentFilmStrips()
        presentTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //trying to hide navbar
        //self.navigationController?.isNavigationBarHidden = true
        //hide on scroll?
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @objc func filmTapped(_ sender:UIButton!) {
        print("film roll tapped")
        
        //remove -1 if needed
        selectedRoll = sender.tag - 1
        moveToFilmRoll()
    }
    
    @objc func backArrowTapped(_ sender:UIButton) {
        print("print back arrow tapped")
        moveHome()
    }
    
    //WORKING HERE
    func presentFilmRolls() {
        let rollCount = numRolls + 1
        
        for i in stride(from: 1, to: rollCount, by: 1) {
            
            let newY = (i * 125) + 25
        
            let image = UIImage(named: "filmRoll.png")
            let thisButton = UIButton()
            thisButton.frame = CGRect(x: 50, y: newY, width: 100, height: 100)
            thisButton.setBackgroundImage(image, for: UIControl.State.normal)
            thisButton.addTarget(self, action: #selector(filmTapped(_:)), for: .touchUpInside)
            //thisButton.tag = i-1
            thisButton.tag = rollCount - i
            filmRollButtonArray.append(thisButton)
            
            let index = i - 1
            scrollView.addSubview(filmRollButtonArray[index])
        }
    }
    
    func presentFilmRollLabels() {
        let labelCount = numRolls + 1
        
        for i in stride(from: 1, to: labelCount, by: 1) {
            let newY = i * 125 + 58
            let sampleTextField =  UITextField(frame: CGRect(x: 140, y: newY, width: 200, height: 25))

            //sampleTextField.text = rollManager.filmRollArray[i-1].title
            sampleTextField.text = rollManager.filmRollArray[(labelCount - 1) - i].title
            

            sampleTextField.font = UIFont.systemFont(ofSize: 15)
            sampleTextField.textColor = .white
            //sampleTextField.backgroundColor = UIColor(red: 0.23, green: 0.52, blue: 1, alpha: 0.75)
            sampleTextField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            sampleTextField.borderStyle = UITextField.BorderStyle.roundedRect
            sampleTextField.autocorrectionType = UITextAutocorrectionType.no
            sampleTextField.keyboardType = UIKeyboardType.default
            sampleTextField.returnKeyType = UIReturnKeyType.done
            sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
            sampleTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
            sampleTextField.delegate = self
            //sampleTextField.tag = i-1
            sampleTextField.tag = labelCount - i
            
            filmRollLabelArray.append(sampleTextField)
            
            let index = i - 1
            scrollView.addSubview(filmRollLabelArray[index])
            
            //updating endingY for bottomStrip
            endingY = newY + 125
        }
    }
    
    func presentFilmStrips() {
        let imageName = "filmStripRainbow.png"
        let image = UIImage(named: imageName)
        let bottomStrip = UIImageView(image: image!)
        
        let minHeight = frameHeight - 100
        let endingYInt = Int(endingY)
        if (Int(minHeight) > endingYInt) {
            bottomStrip.frame = CGRect(x: 0, y: Int(minHeight), width: Int(frameWidth), height: 75)
        }
        else {
            bottomStrip.frame = CGRect(x: 0, y: Int(endingY), width: Int(frameWidth), height: 75)
        }
        view.addSubview(bottomStrip)
    }
    
    func setNewFilmRollName() {
        var size = rollManager.filmRollArray.count
        
        size = size - 1
        
        for i in 0...size {
            filmRollNameArray[i] = rollManager.filmRollArray[i].title
        }
        rollManager.write()
    }
    
    func presentTitle() {
        let imageName = "filmRolls.png"
        let image = UIImage(named: imageName)
        let title = UIImageView(image: image!)
        let thisWidth = Int(frameWidth) - 20
        let thisHeight = Int(thisWidth/4)
        title.frame = CGRect(x: 10 , y: 50, width: thisWidth, height: thisHeight)
        view.addSubview(title)
    }
    
    func moveToFilmRoll() {
        let mainCollectionView = self.storyboard?.instantiateViewController(withIdentifier: "MainCollectionVC") as! MainCollectionViewController
        self.navigationController?.pushViewController(mainCollectionView, animated: true)
    }
    
    func moveHome() {
        let homeView = self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerVC") as! ViewController
        self.navigationController?.pushViewController(homeView, animated: true)
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

    func readImages() {
        //read and print image names
        let fileManager = FileManager.default
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathString = path.path
        
        //checking user documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let items = try! fileManager.contentsOfDirectory(atPath: pathString)

        for item in items {
            //adding images to the image array and printing image names
            if item.hasSuffix(".jpg") {
                print("I found an item: ")
                print(item)
                print(" ")
                imageNameArray.append(item)
            }
            print("dumping image name array: ")
            dump(imageNameArray)
        }
    }
    
    func saveNewTitle(thisTextField: UITextField) {
        let newText = thisTextField.text
        let temp = thisTextField.tag - 1
        rollManager.filmRollArray[temp].title = newText!
        rollManager.write()
    }
    
    //testing saving image
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
    
    
}

extension FilmLibraryViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // return NO to disallow editing.
        print("TextField should begin editing method called")
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // became first responder
        print("TextField did begin editing method called")
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
        print("TextField should snd editing method called")
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
        print("TextField did end editing method called")
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // if implemented, called in place of textFieldDidEndEditing:
        print("about to call save name method")
        saveNewTitle(thisTextField: textField)
        print("after saveNewTitleCalled")
        print("TextField did end editing with reason method called")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        print("While entering the characters this method gets called")
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // called when clear button pressed. return NO to ignore (no notifications)
        print("TextField should clear method called")
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        print("TextField should return method called")
        textField.resignFirstResponder()
        return true
    }

}
