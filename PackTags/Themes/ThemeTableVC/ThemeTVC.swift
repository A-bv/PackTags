//
//  ThemeTableViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeTableViewController: UITableViewController {
    
    @IBOutlet weak var addThemeButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var analyticsButton: UIBarButtonItem!
    
    var isTableViewEditMode = false
    
    var themes = [ThemeCD](){
        didSet {
            //reloadeding after adding a new theme (safe)
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //showOnboardingScreen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TTVCrefreshUI()
        
        //(fix p1)
        self.view.isUserInteractionEnabled = true
        
        OperationQueue.main.addOperation {
            //(p1): fast clicks opens views multiple times
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initial UI
        TTVCsetUI()
        
        //Content
        themes = CoreDataHelper.retrieveThemes()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //OnBoarding
        if Core.shared.isNewUser() {
            self.showOnboardingScreen()
        }
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //(fix p1)
        self.view.isUserInteractionEnabled = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
   

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as? ThemeCell
        else {
            fatalError("The dequeued cell is not an instance of ThemeTableViewCell.")
        }
        
        // Fetches the appropriate theme for the data source layout.
        let theme = themes[indexPath.row]
        
        cell.nameLabel.text = theme.name
            
        if theme.thumbnail == nil {} else {
            let new = UIImage(data: theme.thumbnail!)
            cell.themeImageView.image = new
        }
           
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                presentDeletionFailsafe(indexPath: indexPath)
            }   else if editingStyle == .insert {}
        }
    }
    
    //OPTIONAL: Reorder tableView * -
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return self.tableView.isEditing == true ? .none : .delete
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = bkgdColor
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.themes[sourceIndexPath.row]
        themes.remove(at: sourceIndexPath.row)
        themes.insert(movedObject, at: destinationIndexPath.row)
        
        //tableView.reloadData()
        
        for (index, element) in themes.enumerated() {
            element.orderIndex = Int32(index)
        }
        CoreDataHelper.saveTheme()
    }
    // - *
    
    
    
}


//custom status bar in all view controllers (csb)
extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}

//Confirm row deletion
extension ThemeTableViewController {
    func presentDeletionFailsafe(indexPath: IndexPath) {
            let alert = UIAlertController(title: nil, message: "Delete this theme?\n\nThis action is unreversible", preferredStyle: .alert)

            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                
                //Delete row code
                let themeToDelete = self.themes[indexPath.row]
                CoreDataHelper.delete(theme: themeToDelete)
                self.themes = CoreDataHelper.retrieveThemes()
                self.tableView.deleteRows(at: [indexPath], with: .none)
                
            }

            alert.addAction(yesAction)

            // cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }

}





