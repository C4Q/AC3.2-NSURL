//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-1
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

struct InstaCat {
    
    var name: String
    var cat_id: Int
    var instagram: String
    var description: String = "Hi I'm (\name)"
    
}

class InstaCatTableViewController: UITableViewController {
    
   
    
    
    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        guard let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatsData: Data = self.getData(from: instaCatsURL),
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatsData) else {
                return
        }
        
        self.instaCats = instaCatsAll
      
    }



    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instaCats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CatInstagramTableViewCell = tableView.dequeueReusableCell(withIdentifier: "InstaCatCellIdentifier", for: indexPath) as! CatInstagramTableViewCell
        
        let catInfo = self.instaCats[indexPath.row]
        cell.setData(instaCats: catInfo)

        
        
        //cell.detailTextLabel?.text = String(instaCats[indexPath.row].cat_id)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let url = URL(string: instaCats[indexPath.row].instagram) {
            UIApplication.shared.open(url, options: [:])
        }
        
    }
    
    
    
    //MARK: Helper Functions
    
    internal func getResourceURL(from fileName: String) -> URL? {
        
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound)
        let fileExtensionComponent: String = fileName.substring(from: dotRange.upperBound)
        
        let fileURL: URL? = Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtensionComponent)
        
        return fileURL
    }
    
    internal func getData(from url: URL) -> Data? {
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
    
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            // 3. Check for keys "name", "cat_id", "instagram", making sure to cast values as needed along the way
            if let catDict = instaCatJSONData as? [String:[[String:Any]]] {
                if let catData = catDict["cats"] {
                    for cats in catData {
                        if let name = cats["name"] as? String,
                            let idString = cats["cat_id"] as? String,
                            let instagram = cats["instagram"] as? String
                             {
                            
                            guard let id = Int(idString) else {return nil}
                            
                            let instagramCat = InstaCat(name: name, cat_id: id, instagram: instagram, description: description)
                            
                            instaCats.append(instagramCat)
                            
                            
                            /* //If you use this, would have to convert a few parameters when putting value in TVC
                             let instagramCat = InstaCat(name: name, catID: idString, instagramURL: instagramURL)
                             
                             instaCats.append(appendCats)
                             */
                            
                        }
                    }
                }
            }
        }
        
        
        
        
        catch let error as NSError {
            // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }
    
    
}
