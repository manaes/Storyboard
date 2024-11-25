# StoryboardHelper?

StoryboardHelper make code simple.

Before:
```
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController

let storyboard2 = UIStoryboard(name: "Test", bundle: nil)
let testVC = storyboard2.instantiateViewController(withIdentifier: "TestViewController") as! TestViewController
```

After:
```
try await Storyboard().controller(MainViewController.self)
try await Storyboard().controller(TestViewController.self)
```

- You can instantiate objects using only their storyboard IDs, regardless of storyboard parsing.
- You can retrieve casted objects directly without the need for forced type casting.
- Supports direct object creation and initialization protocols.

### Integraation

#### Swift Package Manager

```
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/manaes/StoryboardHelper.git", from: "1.0.0"),
    ]
)
```

### Usage

#### Initialization

```
import StoryboardHelper
```

#### Input class name into storyboard id

![storybard](https://github.com/user-attachments/assets/bacc43c3-4eaa-4a31-9aa9-e544ca0190c9)

#### Code

```
let testVC = StoryboardUtil().controller(from: TestViewController.self)  
testVC.value = 1
```

or

```
let testViewModelVC = try Storyboard().controller(TestViewModelController.self) { coder in
  TestViewModelController(
    viewModel: TestViewModel(),
    coder: coder
 )
}
testViewModelVC.name = "test"
```


