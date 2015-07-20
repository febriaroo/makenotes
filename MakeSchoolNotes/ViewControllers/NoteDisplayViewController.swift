//
//  NoteDisplayViewController.swift
//  MakeSchoolNotes
//
//  Created by Febria Roosita Dwi on 6/29/15.
//  Copyright (c) 2015 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import ConvenienceKit

class NoteDisplayViewController: UIViewController {
    
    
   
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    @IBOutlet weak var toolbarBottomSpace: NSLayoutConstraint!

    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
   
    var keyboardNotificationHandler: KeyboardNotificationHandler?
    
    var edit : Bool!{
        didSet {
            edit = false
        }
    }
    
    var note: Note? {
        didSet {
            displayNote(note)
        }
    }
    //MARK: Business Logic
    
    func displayNote(note: Note?) {
        if let note = note, titleTextField = titleTextField, contentTextView = contentTextView  {
            titleTextField.text = note.title
            contentTextView.text = note.content
            
            if count(note.title)==0 && count(note.content)==0 { //1
                titleTextField.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayNote(note)
        
        titleTextField.returnKeyType = .Next //1        
        titleTextField.delegate = self     //2
        
        keyboardNotificationHandler = KeyboardNotificationHandler()
        
        
        keyboardNotificationHandler!.keyboardWillBeHiddenHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3){
                self.toolbarBottomSpace.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardNotificationHandler!.keyboardWillBeShownHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                self.toolbarBottomSpace.constant = -height
                self.view.layoutIfNeeded()
            }
        }
        
        if (edit != nil) {
            deleteButton.enabled = false
        }
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        note = Note()
        note!.title   = "Super Simple New Note"
        note!.content = "Yet More Content"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveNote()
    }
    
    func saveNote() {
        if let note = note {
            let realm = Realm()
            
            realm.write {
                if (note.title != self.titleTextField.text || note.content != self.contentTextView.text) {
                    note.title = self.titleTextField.text
                    note.content = self.contentTextView.text
                    note.modificationDate = NSDate()
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension NoteDisplayViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == titleTextField {
            contentTextView.returnKeyType = .Done
            self.contentTextView.becomeFirstResponder()
        }
        
        return true
    
    }
}
