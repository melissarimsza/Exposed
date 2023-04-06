//
//  ViewController.swift
//  Exposed
//
//  Created by Melissa Rimsza on 10/4/22.
//


/*
 working on getting the new film library view to work
 current issue:
    view controller errors when i try to initialize the new film library view
 */

import UIKit
import AVFoundation

//hopefullt unncessary once the filmRollObjects are working
public var numRolls: Int = 0

class ViewController: UIViewController {

    //Capture devices and sessions
    var captureSession : AVCaptureSession!
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var videoOutput : AVCaptureVideoDataOutput!
    
    //my bools
    var takePicture = false
    var backCameraOn = true
    
    //just useful to have
    let frameWidth = UIScreen.main.bounds.width
    let frameHeight = UIScreen.main.bounds.height
    
    //somethign about the ci filters
    let context = CIContext()
    
    //do i need to have a manager oject?
    var rollManager = FilmRollManager()
    
    //Creating the SwitchCameraButton
    let switchCameraButton : UIButton = {
        let button = UIButton()
        let image = UIImage(named: "switchcamera")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Creating Image Capture Button
    let captureImageButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "TakePhoto.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Creating the View Film Nav Button
    let viewFilm : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ViewFilm.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(viewFilm(_:)), for: .touchUpInside)
        return button
    }()
    
    //Creating the capturedImageView object
    let capturedImageView = CapturedImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        //loading the info from the file, so now it should be in that filmRollArray
        rollManager.load()
        numRolls = rollManager.filmRollArray.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Check camera permissions and behin the cpature session
        checkPermissions()
        setupAndStartCaptureSession()
    }
    
    //Adding the URL location of the captured photo to photos array
    func saveURLtoRoll(thisURL: URL) {
        //adding the photourl to the roll array
        
        //Getting and formatting the date
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let timestamp = formatter.string(from: now)
        
        //Getting/ making the correct filmRoll object
        var activeRoll = rollManager.workingRoll()
        //adding the new photo URL
        activeRoll.photos.append(thisURL)
    }
    
    func saveName(thisName: String) {
        //Getting/ making the correct filmRoll object
        var activeRoll = rollManager.workingRoll()
        //adding the new photo URL
        activeRoll.names.append(thisName)
    }
    
    //trying to do the image filters
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage?
    {
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        return sepiaFilter?.outputImage
    }
    
    func chromeFilter(_ input: CIImage) -> CIImage? {
        let chromeFilter = CIFilter(name: "CIPhotoEffectChrome")
        chromeFilter?.setValue(input, forKey: kCIInputImageKey)
        return chromeFilter?.outputImage
    }
    
    func fadeFilter(_ input: CIImage) -> CIImage? {
        let fadeFilter = CIFilter(name: "CIPhotoEffectFade")
        fadeFilter?.setValue(input, forKey: kCIInputImageKey)
        return fadeFilter?.outputImage
    }
    
    func transferFilter(_ input: CIImage) -> CIImage? {
        let transferFilter = CIFilter(name: "CIPhotoEffectTransfer")
        transferFilter?.setValue(input, forKey: kCIInputImageKey)
        return transferFilter?.outputImage
    }
    
    func vibranceFilter(_ input: CIImage) -> CIImage? {
        let vibranceFilter = CIFilter(name: "CIVibrance")
        vibranceFilter?.setValue(input, forKey: kCIInputImageKey)
        let amount = 1
        vibranceFilter?.setValue(amount, forKey: kCIInputAmountKey)
        return vibranceFilter?.outputImage
    }
    
    //SAVING IMAGE TO THE DOCUMENTS
    func saveImageToFile(image: UIImage, jpegQuality: CGFloat = 0.9) {
        var filename = ""
        
        if let data = image.jpegData(compressionQuality: jpegQuality) {
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd_HH-mm-ss-SS"
            let timestamp = formatter.string(from: now)
            
            filename = "photo_\(timestamp).jpg"
            
            //SAVING THE NAME TO NAMES ARRAY
            saveName(thisName: filename)
            
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let pathname = documentsDirectory!.appendingPathComponent(filename)
            
            do {
                try data.write(to: pathname)
            }
            catch {
                print(error.localizedDescription)
            }
            
            //saving the URL to the photos array of active film roll
            saveURLtoRoll(thisURL: pathname)
            
            let fileURL = pathname
            
            do {
                let imageData = try Data(contentsOf: fileURL)
                let saveImage = UIImage(data: imageData)
                UIImageWriteToSavedPhotosAlbum(saveImage!, nil, nil, nil)
            } catch {
                print("Error loading image : \(error)")
            }
        }
        else {
            print("Warning, unable to create jpeg data.")
        }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsDirectory!.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: fileURL.path) {
            print("Image exists at path: \(fileURL.path)")
        } else {
            print("Image does not exist at path: \(fileURL.path)")
        }
    }
    
    //DON'T TOUCH
    //Setting up the camera and capture
    func setupAndStartCaptureSession(){
        DispatchQueue.global(qos: .userInitiated).async{
            //init session
            self.captureSession = AVCaptureSession()
            //start configuration
            self.captureSession.beginConfiguration()
            
            //session specific configuration
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            //setup inputs
            self.setupInputs()
            
            DispatchQueue.main.async {
                //setup preview layer
                self.setupPreviewLayer()
            }
            
            //setup output
            self.setupOutput()
            
            //commit configuration
            self.captureSession.commitConfiguration()
            //start running it
            self.captureSession.startRunning()
        }
    }
    
    //DON'T TOUCH
    //Setting up inputs
    func setupInputs(){
        //get back camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            //handle this appropriately for production purposes
            fatalError("no back camera")
        }
        
        //get front camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            fatalError("no front camera")
        }
        
        //now we need to create an input objects from our devices
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("could not create input device from back camera")
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            fatalError("could not add back camera input to capture session")
        }
        
        guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("could not create input device from front camera")
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            fatalError("could not add front camera input to capture session")
        }
        
        //connect back camera input to session
        captureSession.addInput(backInput)
    }
    
    //DON'T TOUCH
    //Setting up outputs
    func setupOutput(){
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("could not add video output")
        }
        videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    //DONT TOUCH
    //Setting up preview layer
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(previewLayer, below: switchCameraButton.layer)
        previewLayer.frame = self.view.layer.frame
    }
    
    //DONT TOUCH
    //Switch front/back camera
    //CURRENTLY NOT USING COULD MAYBE ADD?
    func switchCameraInput(){
        //don't let user spam the button, fun for the user, not fun for performance
        switchCameraButton.isUserInteractionEnabled = false
        
        //reconfigure the input
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        
        //deal with the connection again for portrait mode
        videoOutput.connections.first?.videoOrientation = .portrait
        
        //mirror the video stream for front camera
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
        
        //commit config
        captureSession.commitConfiguration()
        
        //acitvate the camera button again
        switchCameraButton.isUserInteractionEnabled = true
    }
    
    //Move to FilmLibrary View Controller
    func moveToFilm() {
        print("move to film called")
        let filmView = self.storyboard?.instantiateViewController(withIdentifier: "FilmLibraryVC") as! FilmLibraryViewController
        self.navigationController?.pushViewController(filmView, animated: true)
    }
    
    //DON'T TOUCH
    //Take the photo
    @objc func captureImage(_ sender: UIButton?){
        takePicture = true
    }
    
    //Switch camera button action
    @objc func switchCamera(_ sender: UIButton?){
        switchCameraInput()
    }
    
    //Move to film button action
    @objc func viewFilm(_ sender:UIButton!) {
        moveToFilm()
    }
}

//Mostly working
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !takePicture {
            return //we have nothing to do with the image buffer
        }
        
        //try and get a CVImageBuffer out of the sample buffer
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        //get a CIImage out of the CVImageBuffer
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        let chromeCIImage = chromeFilter(ciImage)
        let vibranceCIImage = vibranceFilter(chromeCIImage!)
        
        //get UIImage out of filtered CIImage
        let uiImage = UIImage(ciImage: vibranceCIImage!)
        

        //HERE
        //saving the image to the file
        saveImageToFile(image: uiImage)
        
        rollManager.write()
        
        DispatchQueue.main.async {
            self.capturedImageView.image = uiImage
            self.takePicture = false
        }
    }
        
}

