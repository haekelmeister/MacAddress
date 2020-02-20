import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MacAddressTests.allTests),
        testCase(MacAddressParseTests.allTests)
    ]
}
#endif
