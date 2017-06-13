//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-1
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

struct InstaCat {
  // add necessary ivars and initilizations; check the tests to know what you should have
    let name: String
    let catID: String
    let instagramURL: String
}

class InstaCatTableViewController: UITableViewController {
    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatData: Data = self.getData(from: instaCatsURL),
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatData)
        else {
            print("Could not get instacats!")
            return
        }
        
        self.instaCats = instaCatsAll
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.instaCats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InstaCatTableViewCellIdentifier, for: indexPath)
        
        let instaCat = self.instaCats[indexPath.row]
        cell.textLabel?.text = instaCat.name
        cell.detailTextLabel?.text = "Nice to meet you, I'm \(instaCat.name)"
        
        return cell
    }
    
    // 1. (input: `String`, output: `URL`)
    internal func getResourceURL(from fileName: String) -> URL? {
        
        let components = fileName.components(separatedBy: ".")
        guard let fileName = components.first,
        let fileExtension = components.last
            else {
                return nil
        }
        
        return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
    
    // 2. (input: `URL`, output: `Data`)
    internal func getData(from url: URL) -> Data? {
        return try? Data(contentsOf: url)
    }
    
    // 3. (input: `Data`, output: [InstaCat])
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        // 1. This time around we'll add a do-catch
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            guard
                let instaCatDict = instaCatJSONData as? [String : AnyObject],
                let instaAllCats = instaCatDict["cats"] as? [[String:String]] else {
                        return nil
            }
            // 3. Check for keys "name", "cat_id", "instagram", making sure to cast values as needed along the way
            var catArr: [InstaCat] = []
            for cat in instaAllCats {
                guard
                    let name = cat["name"],
                    let id = cat["cat_id"],
                    let insta = cat["instagram"]
                else { return nil }
                
                catArr.append(InstaCat(name: name, catID: id, instagramURL: insta))
            }
            
            // 4. Return something
            return catArr
        }
        catch let error as NSError {
            // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }

}
