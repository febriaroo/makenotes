//
//  ViewController.swift
//  MakeSchoolNotes
//
//  Created by Martin Walsh on 29/05/2015.
//  Copyright (c) 2015 MakeSchool. All rights reserved.
//

import UIKit
import RealmSwift

class NotesViewController: UIViewController {
    var selectedNote:Note?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    var state: State = .DefaultMode {
        didSet {
            // update notes and search bar whenever State changes
            switch (state) {
            case .DefaultMode:
                let realm = Realm()
                notes = realm.objects(Note).sorted("modificationDate", ascending: false) //1
                self.navigationController!.setNavigationBarHidden(false, animated: true) //2
                searchBar.resignFirstResponder() // 3
                searchBar.text = ""
                searchBar.showsCancelButton = false
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                searchBar.setShowsCancelButton(true, animated: true) //4
                notes = searchNotes(searchText) //5
                self.navigationController!.setNavigationBarHidden(true, animated: true) //6
            }
        }
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            
            let realm = Realm()
            
            switch identifier {
            case "Save":
                let source = segue.sourceViewController as! NewNoteViewController //1
                
                realm.write() {
                    realm.add(source.currentNote!)
                }
            case "Delete":
                realm.write() {
                    realm.delete(self.selectedNote!)
                }
                
                let source = segue.sourceViewController as! NoteDisplayViewController
                source.note = nil;
    
            default:
                println("No one loves \(identifier)")
            }
            
            notes = realm.objects(Note).sorted("modificationDate", ascending: false) //2
        }
    }
    
    var notes: Results<Note>! {
        didSet {
            // Whenever notes update, update the table view
            
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let realm = Realm()
        notes = realm.objects(Note).sorted("modificationDate", ascending: false)
        state = .DefaultMode
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowExistingNote") {
            let noteViewController = segue.destinationViewController as! NoteDisplayViewController
            noteViewController.note = selectedNote
        }
    }
    
    func searchNotes(searchString: String) -> Results<Note> {
        let realm = Realm()
        let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@ OR content CONTAINS[c] %@", searchString, searchString)
        return realm.objects(Note).filter(searchPredicate)
    }
}
extension NotesViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! NoteTableViewCell //1
        
        /* //this part has been change in to the code bellow
        let row = indexPath.row
        cell.titleLabel?.text = "Hello"
        cell.dateLabel?.text = "Date"
        */
        
        let row = indexPath.row
        let note = notes[row] as Note
        cell.note = note
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /* // this part has been change into the code bellow
        return 5
        */
        return Int(notes?.count ?? 0)
        
    }
    
    
}
extension NotesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedNote = notes[indexPath.row]      //1
        self.performSegueWithIdentifier("ShowExistingNote", sender: self)     //2
    }
    
    // 3
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // 4
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let note = notes[indexPath.row] as Object
            
            let realm = Realm()
            
            realm.write() {
                realm.delete(note)
            }
            
            notes = realm.objects(Note).sorted("modificationDate", ascending: false)
        }
    }
    
}
extension NotesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        notes = searchNotes(searchText)
    }
    
}