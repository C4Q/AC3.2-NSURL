### Exercise Solutions:

**Note** There are many ways of solving the same problem in code. This is just one of several. 

> Please attempt these on your own before looking at these!

---

#### Filling out `getInstaCats(from jsonData: Data) -> [InstaCat]?`

```swift
	internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        // 1. This time around we'll add a do-catch
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            guard let instaCatDict = instaCatJSONData as? [String : AnyObject],
                let instaAllCats = instaCatDict["cats"] as? [[String:String]] 
            else {
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
```

---

#### Populating the Table with our Cats

```swift 
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
```

---

#### Advanced Exercise: Rewriting `getResourceURL(from fileName: String) -> URL?`

```swift
	internal func getResourceURL(from fileName: String) -> URL? {
        // 1. `rangeOfCharacter(from:)` to get the index of the `.` in the string 
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        // Note:  The upperbound of a range represents the position following the last position in the range, thus we can use it
        // to effectively "skip" the "." for the extension range

        // 2. `.substring(to:)` to get the string that represents the filename
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound)

        // 3. `.substring(from:)` to get the string that represents the file extension
        let fileExtenstionComponent: String = fileName.substring(from: dotRange.upperBound)
        
        return Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtenstionComponent)
    }
```