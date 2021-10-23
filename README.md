# ERStepperView

Stunning Swift component for stepper.

![Image of Neumorphic Label](https://file.io/ckXFzhWDi5eq)

## Installation
Requirements
.iOS(.v11)

#### Swift Package Manager 
1. In Xcode, open your project and navigate to File → Swift Packages → Add Package Dependency.
2. Paste the repository URL (https://github.com/RichYourMind/ERStepperView.git) and click Next.
3. For Rules, select version.
4. Click Finish.

#### Swift Package
```swift
.package(url: "https://github.com/RichYourMind/ERStepperView.git")
```
## Usage
Import ERStepperView package to your class.

```swift
import ERStepperView
```

 Drag custom view to your stroyboard and change its class to ERStepperView. Set its width and height constraint as you want.

![Image of usage](https://i.postimg.cc/ZKH4D335/Screen-Shot-2021-10-23-at-11-29-56-AM.png)

## Customize
Modify font and main color from your class. Just make outlet from stepper view to your code.
Simply use **.font** and **.primaryColor** properties to set font and color for view.
```swift
stepperView.primaryColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
stepperView.font = UIFont.systemFont(ofSize: 25, weight: .bold)
```

## Delegate
To get notifyed when ever stepper changes just set your class as stepperview delegate
```swift
stepperView.delegate = self
```

Now just implement this delegate method to be notified
```swift
extension ViewController: StepperDelegate {
    func stepperViewIsShowing(index: Int) {}
}
```


## Contacts
implementedmind@gmail.com
