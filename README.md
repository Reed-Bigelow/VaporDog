# VaporDog

This is an Unofficial DataDog package for Vapor. Currently there is no Vapor package for DataDog and the goal of this project is to bridge that gap.

## Projects
- [x] Logging
- [ ] Metrics
- [ ] Tracing
- [ ] Events

## Logging
To implement logging at a project level just bootstrap the logger at run time before creating the ```Application(env:)```.
```swift
LoggingSystem.bootstrap { _ in
    return DataDogLogger(apiKey: "api_key", source: "source_name", service: "service_name", hostname: "10.0.1.1")
}
```
There is a minimum of 10 logs before the system attempts to send them to DataDog. If 10 or less logs are produced within 5 seconds any remaining logs will be pushed up.
