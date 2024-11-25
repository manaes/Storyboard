//
//  TestViewController.swift
//  StoryboardHelper
//
//  Created by 2024 Wanny Park.
//

import UIKit

/**
 *  Exist storyboard id
 */
final class TestViewController: UIViewController { }

/**
 *  Exist storyboard id with view model
 */
final class TestViewModel: NSObject { }

final class TestViewModelController: UIViewController {
  private var viewModel: TestViewModel
  
  init?(viewModel: TestViewModel, coder: NSCoder) {
    self.viewModel = viewModel
    super.init(coder: coder)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("required init error!!")
  }
}

/**
 *  Not Exist storyboard id
 */
final class TestFailViewController: UIViewController { }
