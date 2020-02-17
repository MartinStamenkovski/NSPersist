# NSPersist

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
- [ ] CloudKit
- [ ] Hard migrations

## Usage

Check out the [Documentation](https://martinstamenkovski.github.io/NSPersist/) for more information.

Example usage of get request or `fetch`
```swift
NSPersist.shared
.request(NSExampleDogF.self) { (request) in
    request.predicate = NSPredicate(format: "nsexampleuser.name = %@", "Test")
    request.sortDescriptors = [.init(key: "name", ascending: false)]
}.get()
```
returns list of dogs where user name is *Test*.

As I said this is a lightweight wrapper, you are still working with the `NSFetchRequest` that you get from the completion block.
