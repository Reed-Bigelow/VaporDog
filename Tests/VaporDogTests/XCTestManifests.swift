import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LogManagerTests.allTests),
        testCase(DataDogLoggerTests.allTests)
    ]
}
#endif
