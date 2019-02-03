# Virtual Tourist

The Virtual Tourist project is result of **Udacity's iOS Developer Nanodegree** course.

The Virtual Tourist app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour. Users will then be able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.

## Screenshots

Travel Map Screen       |  Album Screen
:-------------------------:|:-------------------------:
![Travel Map Screen](https://raw.githubusercontent.com/alhilali/Virtual-Tourist/master/Screenshots/TravelMapScreen.png) | ![Album Screen](https://raw.githubusercontent.com/alhilali/Virtual-Tourist/master/Screenshots/AlbumScreen.png)

## Installation
1. Download project zip or clone the repo https://github.com/alhilali/Virtual-Tourist.git.
2. Navigate to the project folder in Terminal.
3. Run pod install to install external libraries
3. Open Virtual Tourist.xcworkspace.
4. Build and Run in iOS Simulator or on your device.

## About Virtual Tourist
The app has two view controller scenes:

- **MapController** - shows the map and allows user to drop pins around the world. Users can drag pin to a new location after
dropping them. As soon as a pin is dropped photo data for the pin location is fetched from Flickr. The actual photo
downloads occur in the CollectionController.

- **CollectionController** - allow users to download photos and edit an album for a location. Users can create new
collections and delete photos from existing albums.

Application uses CoreData to store Pins (`NSManagedObjectContext.executeFetchRequest`) and Photos 
(`NSFetchedResultsController`) objects. All API calls run in background (`NSURLSession.dataTaskWithRequest`).
Preloaded files saved in memory cache (`NSCache`) and file system (`NSFileManager`) and removed as soon as Photo object 
removed from CoreData.



## Requirements

- Xcode 10.1
- Swift 4.2
- CocoaPods installed (https://guides.cocoapods.org/using/getting-started.html)

## License

Copyright (c) 2019 Saud Alhelali https://saud.tech

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
