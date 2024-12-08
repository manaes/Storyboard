//
//  StoryboardHelper.swift
//
//  Created by 2024 Wanny Park.
//

import Foundation
import UIKit

enum StoryboardError: Error {
    case notFound
}

@MainActor
final public class Storyboard: NSObject {
    /// Shared singleton instance with board names
    private static let shared = Storyboard()
    /// Exclude storyboard
    private let excludeBoards = ["LaunchScreen"]
    /// Loaded storyboad name list
    private var boards: Set<String> = []
    /// Bundle path
    private static var bundle: Bundle =
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
        Bundle.module
    } else {
        Bundle.main
    }
    
    /**
     *  Load storyboard fIle names
     */
    private static func checkBoardList() {
        if Storyboard.shared.boards.isEmpty {
            let filesEnumerator = FileManager.default.enumerator(atPath: Storyboard.bundle.bundlePath)!
            while let file = filesEnumerator.nextObject() as? String {
                if let name = Storyboard.getStorybaordName(file), !Storyboard.shared.excludeBoards.contains(name) {
                    Storyboard.shared.boards.insert(name)
                }
            }
        }
    }
    
    /**
     *  Geet storyboard name
     */
    private static func getStorybaordName(_ fileName: String) -> String? {
        if !fileName.hasSuffix(".storyboardc") { return nil }
        return fileName.components(separatedBy: ".storyboardc").first
    }
    
    /**
     Validate storyboard identifiers
     (must same storyboard ID and class name)
     
     Add Run Script Phase:
     
     ```
     #!/bin/bash
     "$SRCROOT"/../../../Scripts/SwiftLintRunScript.sh
     swift /path/to/validate_storyboards.swift
     ```
     
     - parameter from: ViewController's storyboard  ID (== class name)
     
     - returns: ViewController object
     */
    public static func validateStoryboardIdentifiers() throws {
        let bundle = Bundle.main
        let filesEnumerator = FileManager.default.enumerator(atPath: bundle.bundlePath)!
        var storyboards: Set<String> = []

        // 1. 모든 .storyboardc 파일을 탐색
        while let file = filesEnumerator.nextObject() as? String {
            if file.hasSuffix(".storyboardc"), let name = file.components(separatedBy: ".storyboardc").first {
                storyboards.insert(name)
            }
        }

        // 2. 스토리보드 로드 및 identifier 검증
        for storyboardName in storyboards {
            let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
            guard let identifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: String] else {
                continue
            }

            for identifier in identifiers.keys {
                if NSClassFromString(identifier) == nil {
                    throw NSError(
                        domain: "StoryboardValidation",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Storyboard '\(storyboardName)'의 ID '\(identifier)'에 해당하는 ViewController 클래스가 없습니다."]
                    )
                }
            }
        }
    }
    
    /**
     Get viewController from storyboard with storyboard ID
     (must same storyboard ID and class name)
     
     Example:
     
     ```
     let vc = try Storyboard.controller(TestViewController.self)
     ```
     
     ```
     let vc = try Storyboard.controller(TestViewController.self) { coder in
     TestViewController(
     viewModel: TestViewModel(coordinator: self),
     coder: coder
     )
     }
     ```
     
     - parameter from: ViewController's storyboard  ID (== class name)
     
     - returns: ViewController object
     */
    @MainActor
    public static func controller<T: UIViewController>(_ from: T.Type, creator: ((NSCoder) -> T?)? = nil) throws -> T {
        Storyboard.checkBoardList()
        let name = String(describing: from)
        for sotyrboardName in Storyboard.shared.boards {
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: bundle)
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: String], availableIdentifiers[name] != nil {
                if let creator {
                    return storyboard.instantiateViewController(identifier: name, creator: creator)
                }
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        throw StoryboardError.notFound
    }
    
    /**
     Get viewController from storyboard with storyboard ID
     (must same storyboard ID and class name)
     
     Example:
     
     ```
     let vc = Storyboard.instance(TestViewController.self)
     ```
     
     ```
     let vc = Storyboard.instance(TestViewController.self) { coder in
     TestViewController(
     viewModel: TestViewModel(coordinator: self),
     coder: coder
     )
     }
     ```
     
     - parameter from: ViewController's storyboard  ID (== class name)
     
     - returns: ViewController object
     */
    @MainActor
    public static func instance<T: UIViewController>(_ from: T.Type, creator: ((NSCoder) -> T?)? = nil) -> T {
        Storyboard.checkBoardList()
        let name = String(describing: from)
        for sotyrboardName in Storyboard.shared.boards {
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: bundle)
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: String], availableIdentifiers[name] != nil {
                if let creator {
                    return storyboard.instantiateViewController(identifier: name, creator: creator)
                }
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        return UIViewController() as! T
    }
}
