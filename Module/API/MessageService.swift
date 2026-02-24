//
//  MessageService.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 11.02.2026.
//

import Foundation
import Firebase

struct MessageService {
    
    static func fetchMessage(otherUser: User, completion: @escaping([Message]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var messages = [Message]()
        let query = Collection_Message.document(uid).collection(otherUser.uid).order(by: "timestamp")
        
        query.addSnapshotListener { snapshot, error in
            guard let documentChanges = snapshot?.documentChanges.filter({$0.type == .added}) else {return}
            messages.append(contentsOf: documentChanges.map({Message(dictionary: $0.document.data())}))
            completion(messages)
        }
    }
    
    static func fetchRecentMessages(completion: @escaping([Message]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = Collection_Message.document(uid).collection("recent-message").order(by: "timestamp")
        query.addSnapshotListener { snapshot, _ in
            guard let documentChanges = snapshot?.documentChanges else { return }
            let messages = documentChanges.map({Message(dictionary: $0.document.data())})
            completion(messages)
        }
    }
    
    static func uploadMessage(message: String = "", imageURL: String = "", videoURL: String = "", audioURL: String = "", locationURL: String = "", currentUser: User, otherUser: User, unReadCount: Int, completion: ((Error?) -> Void)?) {
        let dataFrom: [String: Any] = [
            "text" : message,
            "fromID": currentUser.uid,
            "toID": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            
            "username": otherUser.username,
            "fullname": otherUser.fullname,
            "profileImageURL": otherUser.profileImageURL,
            
            "new_msg": 0,
            "imageURL": imageURL,
            "videoURL": videoURL,
            "audioURL": audioURL,
            "locationURL": locationURL
        ]
        
        let dataTo: [String:Any] = [
            "text" : message,
            "fromID": currentUser.uid,
            "toID": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            
            "username": currentUser.username,
            "fullname": currentUser.fullname,
            "profileImageURL": currentUser.profileImageURL,
            
            "new_msg": unReadCount,
            "imageURL": imageURL,
            "videoURL": videoURL,
            "audioURL": audioURL,
            "locationURL": locationURL
        ]
        
        Collection_Message.document(currentUser.uid).collection(otherUser.uid).addDocument(data: dataFrom) { _ in
            Collection_Message.document(otherUser.uid).collection(currentUser.uid).addDocument(data: dataTo, completion: completion)
            Collection_Message.document(currentUser.uid).collection("recent-message").document(otherUser.uid).setData(dataFrom)
            Collection_Message.document(otherUser.uid).collection("recent-message").document(currentUser.uid).setData(dataTo)
        }
    }
    
    static func fetchSingleRecentMessage(otherUser: User, completion: @escaping(Int) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Collection_Message.document(otherUser.uid).collection("recent-message").document(uid).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else {
                completion(0)
                return
            }
            
            let message = Message(dictionary: data)
            completion(message.new_msg)
        }
    }
    
    static func markReadAllMessages(otherUser: User) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let dataUpdate: [String : Any] = [
            "new-msg": 0
        ]
        
        Collection_Message.document(uid).collection("recent-message").document(otherUser.uid).updateData(dataUpdate)
    }
    
    static func deleteMessages(otherUSer: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Collection_Message.document(uid).collection(otherUSer).getDocuments { snapshot, _ in
            snapshot?.documents.forEach({document in
                let documentID = document.documentID
                Collection_Message.document(uid).collection(otherUSer).document(documentID).delete()
            })
            
            let ref = Collection_Message.document(uid).collection("recent-message").document(otherUSer)
            ref.delete(completion: completion)
        }
    }
}


