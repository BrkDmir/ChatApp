//
//  ExtensionChatViewController.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 18.02.2026.
//

import UIKit
import SDWebImage
import ImageSlideshow
import SwiftAudioPlayer

extension ChatViewController {
    
    @objc func handleCamera() {
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image"]
        present(imagePicker, animated: true)
        
        print("camera")
    }
    
    @objc func handleGallery() {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
        
        print("gallery")
    }
    
    @objc func handleCurrentLocation() {
        FLocationManager.shared.start { info in
            guard let latitude = info.latitude else {return}
            guard let longitude = info.longitude else {return}
            
            self.uploadLocation(latitude: "\(latitude)", longitude: "\(longitude)")
            FLocationManager.shared.stop()
        }
    }
    
    @objc func handleGoogleMaps() {
        let controller = ChatMapViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func uploadLocation(latitude: String, longitude: String) {
        let locationURL = "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)"
        
        self.showLoader(true)
        MessageService.fetchSingleRecentMessage(otherUser: otherUser) { unReadCount in
            MessageService.uploadMessage(locationURL: locationURL, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadCount + 1) { error in
                self.showLoader(false)
                
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
            }
        }
    }
}


//MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true) {
            guard let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String else {return}
            
            if mediaType == "public.image" {
                // upload image
                
                guard let image = info[.editedImage] as? UIImage else {return}
                self.uploadImage(withImage: image)
            } else {
                guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {return}
                self.uploadVideo(withVideoURL: videoURL)
            }
        }
    }
}

// MARK: - Upload Media

extension ChatViewController {
    func uploadImage(withImage image: UIImage) {
        showLoader(true)
        FileUploader.uploadImage(image: image) { imageURL in
            MessageService.fetchSingleRecentMessage(otherUser: self.otherUser) { unReadMessageCount in
                MessageService.uploadMessage(imageURL: imageURL ,currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadMessageCount + 1) { error in
                    self.showLoader(false)
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
    
    func uploadVideo(withVideoURL url: URL) {
        showLoader(true)
        FileUploader.uploadVideo(url: url) { videoURL in
            MessageService.fetchSingleRecentMessage(otherUser: self.otherUser) { unreadMessageCount in
                MessageService.uploadMessage(videoURL: videoURL, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unreadMessageCount + 1) { error in
                    self.showLoader(false)
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                        return
                    }
                }
            }
        } failure: { error in
            print("error: \(error)")
            return
        }
    }
}

// MARK: - ChatCellDelegate

extension ChatViewController: ChatCellDelegate {
    func cell(wantToPlayVide cell: ChatCell, videoURL: URL?) {
        guard let videoURL = videoURL else {return}
        let controller = VideoPlayerViewController(videoURL: videoURL)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantToShowImage cell: ChatCell, imageURL: URL?) {
        let slideShow = ImageSlideshow()
        
        guard let imageURL = imageURL else {return}
        
        SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) {
            image,_,_,_,_,_ in
            guard let image = image else {return}
            
            slideShow.setImageInputs([
                ImageSource(image: image)
            ])
            
            slideShow.delegate = self as? ImageSlideshowDelegate
            
            let controller = slideShow.presentFullScreenController(from: self)
            controller.slideshow.activityIndicator = DefaultActivityIndicator()
        }
    }
    
    func cell(wantToPlayAudio cell: ChatCell, audioURL: URL?, isPlay: Bool) {
        
        if isPlay{
            guard let audioURL = audioURL else {return}
            
            SAPlayer.shared.startRemoteAudio(withRemoteUrl: audioURL)
            SAPlayer.shared.play()
            
           let _ = SAPlayer.Updates.PlayingStatus.subscribe { playingStatus in
                print("playingStatus: \(playingStatus)")
               if playingStatus == .ended{
                   cell.resetAudioSettings()
               }
            }
        } else {
            SAPlayer.shared.stopStreamingRemoteAudio()
        }
    }
    
    func cell(wantToOpenGoogleMap cell: ChatCell, locationURL: URL?) {
        guard let  googleURLApp = URL(string: "comgooglemaps://") else {return}
        guard let locationURL = locationURL else {return}
        
        if UIApplication.shared.canOpenURL(googleURLApp){
            UIApplication.shared.open(locationURL)
        } else {
            UIApplication.shared.open(locationURL, options: [:])
        }
    }
}

// MARK: - ChatMapViewControllerDelegate

extension ChatViewController: ChatMapViewControllerDelegate {
    
    func didTapLocation(latitude: String, longitude: String) {
        navigationController?.popViewController(animated: true)
        uploadLocation(latitude: latitude, longitude: longitude)
    }
}

