# SwiftyCss
Use Css rule development iOS App

## Installation

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

**1.** You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```shell
$ brew install carthage
```

**2.** Add  `github "wl879/SwiftyCss"` to ` Cartfile`  into your Xcode project

**3.** Run `carthage update` 

**4.** Drag **`SwiftyCss.framework`**/**`SwiftyNode.framework`**/**`SwiftyBox.framework`** from the appropriate platform directory in `Carthage/Build/` to the “Linked Frameworks and Libraries” section of your Xcode project’s “General” settings.

## Usage



style.css

```css
@lazy true
#root-view {background:#555;}
#center-block {float:center; width:100; height:100; background:#f00;}
```

AppDelegate.swift

```swift
import SwiftyCss

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Css.load(file: Bundle.main.path(forResource: "style", ofType: "css")!)
    
        return true
    }
}
```
ViewController.swift
```swift
class ViewController: CssViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.css(id: "root-view")
        self.view.css(create: "#center-block")        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Css.debugPrint(self.view, deep: true)
    }

}
```

![1](/Users/wl/Sites/Git/screenshots/swiftycss/1.png)

![2](/Users/wl/Sites/Git/screenshots/swiftycss/2.png)



## Documentation

### Css class static methods

* func **Css.load**(file: String)

* func **Css.load**(_ text: String)

* func **Css.refresh**(_ node: NodeProtocol, debug: Bool = false)

### Extension CALayer and UIView attributes and methods

CALayer and UIView conforms to NodeProtocol

* **nodeStyle**: Node.Style
* **init**(tag: String? = nil, id: String? = nil, class clas: String? = nil, style: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil)
* func **getAttribute**(_ key: String) -> Any?
* func **setAttribute**(_ key: String, value: Any?)
* func **css**(tag: String? = nil, id: String? = nil, class: String? = nil, style: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil)
* func **css**(addClass: String)
* func **css**(removeClass: String)
* func **css**(refresh signal: Node.Signal = .normal)
* func **css**(value name: String) -> Any?
* func **css**(property name: String) -> String?
* func **css**(create text: String)
* func **css**(creates list: [String])
* func **css**(query text: String) -> [CALayer]?


###  Support style selector rule

Support base CSS syntax，`id`,` tag`, `class`, and support nestification

```css
CALayer {}
#header {}
#header .btn {}
#abc > .btn {}
#abc + .btn {}
#abc ~ .btn {}
```

Support **pseudo** classes 

```css
CALayer:nth-child(1) {}
CALayer:first-child {}
CALayer:last-child {}
CALayer:root {}
CALayer:empty {}
CALayer:not([width > 100]) {}
```

Support **condition expression**

```
CALayer[width > 100] {}
CALayer[float = left] {}
```

### Support style propertys

* `hidden`

* `width` / `height` / `maxWidth` / `maxHeight` / `minWidth` / `minHeight`

* `top` / `left` / `right` / `bottom`

* `transform`

* `zIndex` or `zPosition`


* `float`

* `contentSize`

* `align`

* `padding` / `paddingTop` / `paddingRight` / `paddingbottom` / `paddingLeft`

* `margin` / `marginTop` / `marginRight` / `marginbottom` / `marginLeft`



* `backgroundColor` or `background`

* `backgroundImage`

* `border` / `borderTop` / `borderRight` / `borderbottom` / `borderLeft`

* `opacity`

* `fill` or `fillColor`

* `mask` or `overflow`

* `radius`

* `shadow`


* `content`

* `textAlign`

* `fontSize`

* `fontName`

* `color`


* `animate`


#### Support AtRule for StyleSheet

* **@lazy**

  `@lazy true` enable lazy load mode

* **@debug**

  `@debug true` enable debug mode, this will print parse messages.

* **@media**

  **e.g.** Definition of landscape style

  ```css
  @madia orientation: landscape {
    ...
  }
  ```

  **Support media features**

  `tvos` | `macos` | `watchos` | `ios` | `iphone` | `ipad` | `ipadpro` 

  `iphone4` (320/480) | `iphone5` (320/568) | `iphone6 ` (375/667) | `iphone6plus` (414/736) 

  `orientation:landscape` | `orientation:portrait`

  **Determine the size of**  `UIScreen.main.bounds` **condition**

  `min-width:xxx` | `max-width:xxx` | `width` 

  `min-height:xxx` | `max-height:xxx` | `height:xxx`

  ​

