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
final class Storyboard: NSObject {
  /// Shared singleton instance with board names
  private static let shared = Storyboard()
  /// Exclude storyboard
  private var excludeBoards = ["LaunchScreen"]
  /// Loaded storyboad name list
  private var boards: Set<String> = []
  /// Bundle path
  private var bundle: Bundle =
  if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
    Bundle.module
  } else {
    Bundle.main
  }
  
  /**
   *  Load storyboard fIle names
   */
  private func checkBoardList() {
    if Storyboard.shared.boards.isEmpty {
      let filesEnumerator = FileManager.default.enumerator(atPath: bundle.bundlePath)!
      while let file = filesEnumerator.nextObject() as? String {
        if let name = getStorybaordName(file), !excludeBoards.contains(name) {
          Storyboard.shared.boards.insert(name)
        }
      }
    }
  }
  
  /**
   *  Geet storyboard name
   */
  func getStorybaordName(_ fileName: String) -> String? {
    if !fileName.hasSuffix(".storyboardc") { return nil }
    return fileName.components(separatedBy: ".storyboardc").first
  }
  
  /**
   Get viewController from storyboard with storyboard ID
   (must same storyboard ID and class name)
   
   Example:
   
   ```
   let vc = try Storyboard().controller(TestViewController.self)
   ```
   
   ```
   let vc = try Storyboard().controller(TestViewController.self) { coder in
   TestViewController(
       viewModel: TestViewModel(coordinator: self),
       coder: coder
    )
   }
   ```
   
   - parameter from: ViewController's storyboard  ID (== class name)
   
   - returns: ViewController object
   */
  public func controller<T: UIViewController>(_ from: T.Type, creator: ((NSCoder) -> T?)? = nil) throws -> T {
    checkBoardList()
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
}
