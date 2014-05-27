# CLog (iOS)

A logging library based on [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) that is used in mysms projects.

## Requirements
* XCode 4.5 or higher
* Apple LLVM compiler
* iOS 5.0 or higher
* ARC


## Installation

### CocoaPods

The recommended approach for installating `CLog` is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation.
For best results, it is recommended that you install via CocoaPods >= **0.15.2** using Git >= **1.8.0** installed via Homebrew.

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
```

Edit your Podfile and add the library:

``` bash
platform :ios, '6.0'
pod 'CLog', :git => 'https://github.com/mysms/clog.git'
```

Install into your Xcode project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open MyProject.xcworkspace
```

Please note that if your installation fails, it may be because you are installing with a version of Git lower than CocoaPods is expecting. Please ensure that you are running Git >= **1.8.0** by executing `git --version`. You can get a full picture of the installation details by executing `pod install --verbose`.

## Contributors

Christoph Lückler ([@oe8clr](https://github.com/oe8clr))
