<p align="center">
 <img width="600" src="https://github.com/MartinStamenkovski/NSPersist/blob/master/logo.png">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-ios%20%7C%20osx%20%7C%20watchos%20%7C%20tvos-blue">
</p>
A simple lightweight Core Data wrapper in Swift.

I created this wrapper mostly to ease my workflow in the projects, if you find it useful feel free to use it and modify it to your needs.

### Currently NSPersist supports:
- [x] Delete. 
- [x] DeleteBatchAsync
- [x] UpdateBatchAsync
- [x] InsertBatchAsync
- [x] getAsync (*fetch async*)
- [x] get (*fetch*)
- [x] UndoManager (iOS), macOS has one by default.
- [x] Lightweight migrations.
- [x] Tests
- [x] Multiple store configurations
- [ ] CloudKit Synchronization


## Usage

Check out the [Documentation](https://martinstamenkovski.github.io/NSPersist/) for more information.

First call `NSPersist.setup(withName: "<#Model name#>")` or `NSPersist.setup(withName: "<#Model name#>", configurations: ["<# Configuration name #>"])` to provide the name of the data model to be used and additional configurations.  
This typically is called in `AppDelegate didFinishLaunchingWithOptions` once.

**Example add record**:

```swift
let note = NSExampleNote(context: .main)
note.title = textFieldTitle.text
note.body = textFieldNote.text
note.createdAt = Date()
note.updatedAt = Date()
note.save()
```
As you can see the main context is accessible via `.main` property, and `note.save()` inserts in the main context by default,  or you can specify another context in its parameter like this `note.save(context: backgroundContext)`.  

**Example usage of get request or `fetch`**
```swift
NSPersist.shared.request(NSExampleNote.self, completion: { (request) in
    request.predicate = NSPredicate(format: "favorite = %d", true)
    request.sortDescriptors = [.init(key: "createdAt", ascending: false)]
}).get()
```
returns list of favorite notes in descending order.

*As I said this is a lightweight wrapper, you are still working with the `NSFetchRequest` that you get from the completion block.*

## License
NSPersist is released under [MIT License](https://github.com/MartinStamenkovski/NSPersist/blob/master/LICENSE)
