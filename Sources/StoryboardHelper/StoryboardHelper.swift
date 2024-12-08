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
