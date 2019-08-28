# Pangako

Simple implementation of Promise.

```swift
let pangako = Pangako<String> { resove, reject in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
        if arc4random_uniform(100) % 2 == 0 {
            resolve("hello")
            
        } else {
            let error = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample error"])
            reject(error)
        }
    })
}
pangako
    .then { print($0) }
    .catch { print($0) }
```