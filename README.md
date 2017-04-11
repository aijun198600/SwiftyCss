# SwiftyCss
Use Css rule development iOS App

## Installation

#### Simple

Drag  **`SwiftyCss.framework`**/**`SwiftyNode.framework`**/**`SwiftyBox.framework`** from `iOS/Release/` or `iOS/Debug/`

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

**1.** You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```shell
$ brew install carthage
```

**2.** Add  **`github "wl879/SwiftyCss"`**  to **` Cartfile`**  into your Xcode project

**3.** Run **`carthage update`**

If you want to view the debug information，run **`carthage update --configuration Debug`**

**4.** Drag **`SwiftyCss.framework`**/**`SwiftyNode.framework`**/**`SwiftyBox.framework`** from the appropriate platform directory in `Carthage/Build/` 

## Usage

#### Example


![1](https://raw.githubusercontent.com/wl879/screenshots/master/swiftycss/basic.gif)

style.css

```css
@lazy true
.body {top:64; bottom:40%; width:100%;}
.footer {bottom:0; width:100%; height:40%; background:#333; auto-size: auto}
.footer CATextLayer {color:#fff; font-size:10; left:10; right:10; top:10; word-wrap: true; auto-size:height;}
@media orientation:landscape {
    .body {top:33;}
}

#test-basic .box {background:#aaa;}
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
class ViewController: UIViewController {

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        self.title = "Test Basic"
        self.view.css(insert:
            ".body#test-basic",
            "   CALayer.box[style=top:10;left:5%;width:43%;height:100]",
            "   CALayer.box[style=top:10;right:5%;width:43%;height:100]",
            "   CALayer.box[style=top:130;left:5%;right:5%;bottom:10]",
            "     CATextLayer[style=float:center;autoSize:auto;fontSize:16;color:#fff;][content=The center of the universe]",
            "UIScrollView.footer > CATextLayer"
        )
        if let text = view.css(query: ".footer > CATextLayer")?[0] as? CATextLayer {
            text.string = 
            css.joined(separator: "\n") +
            "\n------------------------------------------\n" +
            Css.debugPrint(self.view, noprint: true)
        }
    }
    
    override func viewWillLayoutSubviews () {
        super.viewWillLayoutSubviews()
        Css.refresh(self.view)
    }

}
```

#### Example screenshot

![1](https://raw.githubusercontent.com/wl879/screenshots/master/swiftycss/layout.gif)

![1](https://raw.githubusercontent.com/wl879/screenshots/master/swiftycss/style.gif)

![1](https://raw.githubusercontent.com/wl879/screenshots/master/swiftycss/media.gif)

![1](https://raw.githubusercontent.com/wl879/screenshots/master/swiftycss/selector.gif)

## Documentation

### Css module

* **styleSheet**


* func **Css.load**(file: String)

* func **Css.load**(_ text: String)

* func **Css.refresh**(_ node: NodeProtocol, debug: Bool = false)

### Extension CALayer and UIView attributes and methods

CALayer and UIView conforms to NodeProtocol

* **cssStyle**: CAStyle
* **init**(tag: String? = nil, id: String? = nil, class clas: String? = nil, style: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil)
* func **getAttribute**(_ key: String) -> Any?
* func **setAttribute**(_ key: String, value: Any?)
* func **css**(tag: String? = nil, id: String? = nil, class: String? = nil, style: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil)
* func **css**(addClass: String)****
* func **css**(removeClass: String)
* func **cssRefresh**()
* func **css**(value name: String) -> Any?
* func **css**(property name: String) -> String?
* func **css**(insert: String...)
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
CALayer:empty {}
CALayer:not(.box) {}
CALayer:not([width > 100]) {}
```

Support **condition expression**

```
CALayer[width > 100] {}
CALayer[float = left] {}
```

### Support style propertys

**`width`**    **`max-width`**    **`min-width`**    **`height`**    **`max-height`**    **`min-height`**

> pt | number%

**`top`**    **`left`**    **`right`**    **`bottom`**

> pt | number%

**`float`**: 

>  center | auto | top | left

**`align`**:

> right | rightTop | left |  leftTop | bottom | leftBottom |  rightBottom
>
> center | leftCenter | topCenter | bottomCenter | rightCenter

**`margin`**    **`margin-top`**    **`margin-right`**    **`margin-bottom`**    **`margin-left`**

> pt | number%

**`padding`**    **`padding-top`**    **`padding-right`**    **`padding-bottom`**    **`padding-left`**

> pt | number%

**`border`**    **`border-top`**    **`border-right`**    **`border-bottom`**    **`border-left`**

>width || solid/dashed/(interval value) || color

**`shadow`**

> y-offset || x-offset || radius || color

>
>  `opacity`    `fill or fill-color`     `background-color or background`   
>
>  `background-image`    `radius`    `shadow`    `hidden`    `z-index or z-position`  
>
>   `text-align`    `font-size`    `font-name`    `color`    `content`    `word-wrap`
>
>  `auto-size:auto/width/height`    `mask or overflow`    `transform`    `animate` 

#### Support AtRule for **StyleSheet**

* **@lazy**

  `@lazy true` enable lazy load mode

* **@debug**

  > **! Need to import the debug version**

  `@debug all, refresh, status, load, ticker, at-rule, begin, listen, insert`

   enable debug mode, this will print parse messages.

* **@media**

  **e.g.** Definition of landscape style

  ```css
  @madia orientation: landscape {
    ...
  }
  @madia iphone {
    ...
  }
  @madia ipad {
    ...
  }
  @madia min-width:320 {
    ...
  }
  ```

  **Support media features**

  `iphone` | `ipad` | `ipadpro` 

  `iphone4` (320/480) | `iphone5` (320/568) | `iphone6 ` (375/667) | `iphone6plus` (414/736) 

  `orientation:landscape` | `orientation:portrait`

  **Determine the size of**  `UIScreen.main.bounds` **condition**

  `min-width:xxx` | `max-width:xxx` | `width` 

  `min-height:xxx` | `max-height:xxx` | `height:xxx`


