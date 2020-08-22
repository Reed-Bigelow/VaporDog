import Foundation
import XCTest
@testable import VaporDog

final class DataDogLoggerTests: XCTestCase {
    
    func testCreateLogItem() {
        let item = DataDogLogger.createLogItem(level: .error, message: "This is a test message", metadata: ["data_int": .string("10"), "data_double": .string("10.5"), "data_string": .string("test_string")])
        XCTAssertEqual(item.message, "This is a test message")
        XCTAssertEqual(item.status, "error")
        XCTAssertEqual(item.metadata["data_int"] as? Int, 10)
        XCTAssertEqual(item.metadata["data_double"] as? Double, 10.5)
        XCTAssertEqual(item.metadata["data_string"] as? String, "test_string")
    }
    
    func testCreateLogItemWithNestedMetadata() throws {
        let item = DataDogLogger.createLogItem(level: .error, message: "This is a test message", metadata: ["data_int": .string("10"),
                                                                                                            "data_double": .string("10.5"),
                                                                                                            "data_string": .string("test_string"),
                                                                                                            "nested_data": .dictionary(["first_level": .string("first_level_string")])])
        XCTAssertEqual(item.message, "This is a test message")
        XCTAssertEqual(item.status, "error")
        XCTAssertEqual(item.metadata["data_int"] as? Int, 10)
        XCTAssertEqual(item.metadata["data_double"] as? Double, 10.5)
        XCTAssertEqual(item.metadata["data_string"] as? String, "test_string")
        
        let nestedData = try XCTUnwrap(item.metadata["nested_data"] as? [String: Any])
        XCTAssertEqual(nestedData["first_level"] as? String, "first_level_string")
    }
    
    func testCreateLogItemWithDeepNestedMetadata() throws {
        let item = DataDogLogger.createLogItem(level: .error, message: "This is a test message", metadata: ["data_int": .string("10"),
                                                                                                            "data_double": .string("10.5"),
                                                                                                            "data_string": .string("test_string"),
                                                                                                            "nested_data_1": .dictionary(["first_level": .string("first_level_string")]),
                                                                                                            "nested_data_2": .dictionary(["first_level": .dictionary(["second_level": .array([.string("1"),
                                                                                                                                                                                              .string("2"),
                                                                                                                                                                                              .string("3")])
                                                                                                            ])])])
        XCTAssertEqual(item.message, "This is a test message")
        XCTAssertEqual(item.status, "error")
        XCTAssertEqual(item.metadata["data_int"] as? Int, 10)
        XCTAssertEqual(item.metadata["data_double"] as? Double, 10.5)
        XCTAssertEqual(item.metadata["data_string"] as? String, "test_string")
        
        let nestedData1 = try XCTUnwrap(item.metadata["nested_data_1"] as? [String: Any])
        XCTAssertEqual(nestedData1["first_level"] as? String, "first_level_string")
        
        let nestedData2 = try XCTUnwrap(item.metadata["nested_data_2"] as? [String: Any])
        let nestedData2Level1 = try XCTUnwrap(nestedData2["first_level"] as? [String: Any])
        let nestedData2Level2 = try XCTUnwrap(nestedData2Level1["second_level"] as? [Any])
        
        XCTAssertEqual(nestedData2Level2[0] as? Int, 1)
        XCTAssertEqual(nestedData2Level2[1] as? Int, 2)
        XCTAssertEqual(nestedData2Level2[2] as? Int, 3)
    }
    
    func testCreateLogItemWithSuperDeepNestedMetadata() throws {
        let item = DataDogLogger.createLogItem(level: .error, message: "This is a test message", metadata: ["nested_data": .dictionary(["first_level":
                                                                                                                                            .dictionary(["second_level_array":
                                                                                                                                                            .array([.string("1"),
                                                                                                                                                                    .string("2"),
                                                                                                                                                                    .string("3")]),
                                                                                                                                                         "second_level_dictionary": .dictionary([
                                                                                                                                                            "data_int": .string("10"),
                                                                                                                                                            "data_double": .string("10.5"),
                                                                                                                                                            "data_string": .string("test_string"),
                                                                                                                                                            "third_level_dictionary": .dictionary([
                                                                                                                                                                "data_int": .string("10"),
                                                                                                                                                                "data_double": .string("10.5"),
                                                                                                                                                                "data_string": .string("test_string"),
                                                                                                                                                                "fourth_level_dictionary": .dictionary([
                                                                                                                                                                    "data_int": .string("10"),
                                                                                                                                                                    "data_double": .string("10.5"),
                                                                                                                                                                    "data_string": .string("test_string"),
                                                                                                                                                                    ])
                                                                                                                                                                ])
                                                                                                                                                            ])
                                                                                                                                                        ])
                                                                                                                                                    ])
                                                                                                                                                ])
                                                                                                                                                        
        
        let nestedData = try XCTUnwrap(item.metadata["nested_data"] as? [String: Any])
        
        let nestedDataLevel1 = try XCTUnwrap(nestedData["first_level"] as? [String: Any])
        let nestedDataLevel2Array = try XCTUnwrap(nestedDataLevel1["second_level_array"] as? [Any])
        
        XCTAssertEqual(nestedDataLevel2Array[0] as? Int, 1)
        XCTAssertEqual(nestedDataLevel2Array[1] as? Int, 2)
        XCTAssertEqual(nestedDataLevel2Array[2] as? Int, 3)
        
        let nestedDataLevel2Dictionary = try XCTUnwrap(nestedDataLevel1["second_level_dictionary"] as? [String: Any])
        
        XCTAssertEqual(nestedDataLevel2Dictionary["data_int"] as? Int, 10)
        XCTAssertEqual(nestedDataLevel2Dictionary["data_double"] as? Double, 10.5)
        XCTAssertEqual(nestedDataLevel2Dictionary["data_string"] as? String, "test_string")
        
        let nestedDataLevel3Dictionary = try XCTUnwrap(nestedDataLevel2Dictionary["third_level_dictionary"] as? [String: Any])
        
        XCTAssertEqual(nestedDataLevel3Dictionary["data_int"] as? Int, 10)
        XCTAssertEqual(nestedDataLevel3Dictionary["data_double"] as? Double, 10.5)
        XCTAssertEqual(nestedDataLevel3Dictionary["data_string"] as? String, "test_string")
        
        let nestedDataLevel4Dictionary = try XCTUnwrap(nestedDataLevel3Dictionary["fourth_level_dictionary"] as? [String: Any])
        
        XCTAssertEqual(nestedDataLevel4Dictionary["data_int"] as? Int, 10)
        XCTAssertEqual(nestedDataLevel4Dictionary["data_double"] as? Double, 10.5)
        XCTAssertEqual(nestedDataLevel4Dictionary["data_string"] as? String, "test_string")
    }
    
    static var allTests = [
        ("testCreateLogItem", testCreateLogItem),
        ("testCreateLogItemWithNestedMetadata", testCreateLogItemWithNestedMetadata),
        ("testCreateLogItemWithDeepNestedMetadata", testCreateLogItemWithDeepNestedMetadata),
        ("testCreateLogItemWithSuperDeepNestedMetadata", testCreateLogItemWithSuperDeepNestedMetadata)
    ]
}
