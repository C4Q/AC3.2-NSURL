### AC3.2 NSURL/URL 
---

### Objective
To understand the importance, purpose and usage of `URL`'s not only in code, but also in general computer systems.

### Readings
1. [`NSURL` - Apple](https://developer.apple.com/reference/foundation/nsurl)
2. [`URL` - Apple](https://developer.apple.com/reference/foundation/url) (mostly same as the above, `URL` is new to swift and can be used interchangeably with `NSURL`)
3. [`NSBundle` - Apple](https://developer.apple.com/reference/foundation/nsbundle)
4. [`JSONSerialization` - Apple](https://developer.apple.com/reference/foundation/jsonserialization)
3. [`Creating and Modifying an NSURL in Your Swift App` - Coding Explorer Blog](http://www.codingexplorer.com/creating-and-modifying-nsurl-in-swift/)

#### Further Readings:
1. [`About the URL Loading System` - Apple](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i)

---
### 1. Intro To `NSURL/URL`

We've already experienced converting a `Dictionary` into our data model by parsing out its key-value pairs. Additionally, we've noted that `JSON` objects are essentially `Dictionary`s. Taken together, we're now going to show you how to convert `JSON` into a data model by importing in data from a local `.json` file. Now's the time to get our feet wet as converting `JSON` into usable data models is an incredibly common task in mobile development.

Locating a file is done via querying the filesystem using `NSURL/URL`. As briefly stated in the official Apple docs for `NSURL/URL`:

> An NSURL object represents a URL that can potentially contain the location of a resource on a remote server, the path of a local file on disk, or even an arbitrary piece of encoded data.

In the project you will find `Main.storyboard` already containing a `UITableViewController` with an embedded `UINavigationController` that is set to be the "Initial View Controller".

1. Ensure the custom class of the `UITableViewController` is set to `InstaCatTableViewController`
2. Ensure there is one prototype cell with an identifier of `InstaCatCellIdentifier` 
3. Switch over to `InstaCatTableViewController.swift` and add in an `InstaCat` struct to house the data for an `InstaCat`
  ```swift 
    struct InstaCat {
        let name: String
        let catID: String
        let instagramURL: String
    }
  ```
4. Now add in the following instance variables to the `InstaCatTableViewController` class
```swift
    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []
```

### 2. Planning out your code

Let's start getting used to creating our functions before we start typing them out completely. This will help to understand that a little bit of planning and preparation can go a long way in development. How exactly do we know what we'll need though? We should think of the task as being a series of functions that take an *input* and return some *output*. Our goal is to locate a file, get the data of that file, and try to create `[InstaCat]` from that data. Combining those two concepts (series of functions and goals) we can derive a good estimate of what we'll need: 

1. We're going to need some way to locate the local `InstaCats.json` file (meaning, we'll need to create a `URL`)
    - This indicates we may want a function that takes the name of our file as a `String` and returns a path to it as a `URL` (input: `String`, output: `URL`)
2. We have to somehow take the contents of `Instacats.json` and convert it into a `Data` object for further conversion
    - We're probably going to want to have a function that accepts the `URL` from the previous step, and returns all of the contents of that file as `Data` (input: `URL`, output: `Data`)
3. We know that we're going to need to create an array of `InstaCat` from `Data`. 
    - That means we know that the *input* to a function will be `Data` and its *output* is going to be `[InstaCat]`, but in all likelihood (and as is common practice) we should not guarantee that the data will create `[InstaCat]` so we return an optional. 

So, from the above we can come up with a basic skeleton of three functions we're going to need to write. Go ahead and review this snippet and add it into your table view controller:

```swift
    // 1. (input: `String`, output: `URL`)
    internal func getResourceURL(from fileName: String) -> URL? {
        
        return nil 
    }
    
    // 2. (input: `URL`, output: `Data`)
    internal func getData(from url: URL) -> Data? {
        
        return nil
    }

    // 3. (input: `Data`, output: [InstaCat])
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        
        return nil
    }
```
  > Note: I have a preference for immediately adding a return value for functions that I write that expect one. I do this only because I prefer not to see pre-compiler errors.
  
And now, in `viewDidLoad`, we can add all of the following, even if we haven't filled out the functions yet:
  
  ```swift 
          guard let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatData: Data = self.getData(from: instaCatsURL), // sorry, this should be Data, not NSData!
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatData) else {
                print("Could not get instacats!")
                return
          }
        
        self.instaCats = instaCatsAll
```

Why do we know that we can write all of this already? Well, we've planned out our code by scaffolding out a series of methods that indicate their function and intent ahead of time. Because these functions are intended to be used sequentially to get from a `String` representing a file's name, all the way to `[InstaCat]`, we can confidently write out our code now and then later return to the implementation of each function. 

---
### 3. Getting a `URL` and `Data`
Each of the projects we've created, compile into a *self-encapsulated* application *bundle* (aka. "app bundle"). The `NSBundle/Bundle` class helps with locating resources within your app's bundle. One of those resources can be a file. For the most part, you're only ever going to be using `Bundle.main` (which refers to the directory within your application bundle where the contents of your project are commonly kept). 

```swift
    internal func getResourceURL(from fileName: String) -> URL? {
        
        // 1. We'll assume that the String passed in will look like <file_name>.<file_extension>
        let components = fileName.components(separatedBy: ".")

        // 2. As long as our input string was formatted properly, we should get an array of string with
        //    the element at [0] being the file's name and [1] being the extension
        guard let fileName = components.first,
            let fileExtension = components.last
        else {
            return nil
        }
        
        // This function type looks like: 
        // Bundle.url(forResource:withExtension:) -> URL? 
        // So we can just return this line instead of assigning the result to a constant first
        return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
```

Getting the `Data` contents of the file located at `fileURL` is fairly straightforward

```swift
    internal func getData(from url: URL) -> Data? {
        
        // 1. this is a simple handling of a function that can throw. In this case, the code makes for a very short function
        // but it can be much larger if we change how we want to handle errors.
        // Note that calling try? will return nil if it fails, rather than throwing an error.
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
```

---
### 4. Exercises

#### Using Tests

1. This project comes with a small test suite. Ensure that your code passes the tests by uncommenting the tests for the sections of code you've written. (You can run tests by pressing `CMD + U`)

2. Using the tests provided and following snippet of code (with hints), finish out the rest of this project so that you can parse out the data contained in `InstaCats.json` to create `[InstaCat]`.

#### InstaCat Model:
```swift
      internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        
        // 1. This time around we'll add a do-catch
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            
            // 3. Check for keys "name", "cat_id", "instagram", making sure to cast values as needed along the way
            
            // 4. Return something
        }
        catch let error as NSError {
          // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
          print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }
```

3. Output the array of `[InstaCat]` to the `InstaCatTableViewController` as pictured below:
![Filling in the tableview](.Images/instacats_1_exercise.png)

#### Advanced Exercise:
1. **String Traversal (Swift 3)**: Re-implement `getResourceURL(from fileName: String) -> URL?`. This time, use:
    - `rangeOfCharacter(from:)` to get the index of the `.` in the string 
    - `.substring(to:)` to get the string that represents the filename
    - `.substring(from:)` to get the string that represents the file extension
