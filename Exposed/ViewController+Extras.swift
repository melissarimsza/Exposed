//
//  ViewController+Extras.swift
//  Exposed
//
//  Created by Melissa Rimsza on 10/4/22.
//

import UIKit
import AVFoundation

//CLEANED
extension ViewController {
    //MARK:- View Setup
    func setupView(){
        
        print("OG VC setupview called")
        view.backgroundColor = .white
        
        view.addSubview(switchCameraButton)
        
        //not sure why but this needs to happen after switch camera button
        let imageName = "Main.png"
        let image = UIImage(named: imageName)
        let mainDisplay = UIImageView(image: image!)
        mainDisplay.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        view.addSubview(mainDisplay)
        
        view.addSubview(capturedImageView)
        view.addSubview(captureImageButton)
        view.addSubview(viewFilm)
       
    NSLayoutConstraint.activate([
        //switch camera button
        switchCameraButton.widthAnchor.constraint(equalToConstant: 30),
        switchCameraButton.heightAnchor.constraint(equalToConstant: 30),
        switchCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        switchCameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
        //take picture button
        captureImageButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -75),
        captureImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 175),
        captureImageButton.widthAnchor.constraint(equalToConstant: 75),
        captureImageButton.heightAnchor.constraint(equalToConstant: 75),
        
        //view film button
        viewFilm.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 115),
        viewFilm.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
        viewFilm.widthAnchor.constraint(equalToConstant: 75),
        viewFilm.heightAnchor.constraint(equalToConstant: 50)
    ])
        switchCameraButton.addTarget(self, action: #selector(switchCamera(_:)), for: .touchUpInside)
        captureImageButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
    }
    
    
    //MARK:- Permissions
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
          case .authorized:
            return
          case .denied:
            abort()
          case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
            { (authorized) in
              if(!authorized){
                abort()
              }
            })
          case .restricted:
            abort()
          @unknown default:
            fatalError()
        }
    }
}

