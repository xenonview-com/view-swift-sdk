# xenon-swift-sdk
The Xenon View Swift SDK is the Swift SDK to interact with [XenonView](https://xenonview.com).

**Table of contents:**

* [What's New](#whats-new)
* [Installation](#installation)
* [How to use](#how-to-use)
* [License](#license)

## <a name="whats-new"></a>
## What's New
* v0.0.1 - Basic Functionality

## <a name="installation"></a>
## Installation

You can install the Xenon View SDK from [Github](https://github.com/xenonview-com/view-swift-sdk):

Via Swift Package Manager by adding to your dependencies section:
```swift
dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url:"https://github.com/xenonview-com/view-swift-sdk", from: "0.0.1"),
        ...
```
Then including as a dependency in your app in the targets section:
```swift
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "<your app name>",
            dependencies: ["xenon_view_sdk"]),
```

## <a name="how-to-use"></a>
## How to use

The Xenon View SDK can be used in your application to provide a whole new level of user analysis and insights. You'll need to embed the instrumentation into your application via this SDK. The basic operation is to create a customer journey by adding steps in the journey like page views, funnel steps and other events. The journey concludes with an outcome. All of this can be committed for analysis on your behalf to Xenon View. From there you can see popular journeys that result in both successful an unsuccessful outcomes. Additionally, you can deanonymize journeys. This will allow for a deeper analysis of a particular user. This is an optional step as just tracking which journey results in what outcome is valuable.

### Instantiation
The View SDK is a JS module you'll need to include in your application. After inclusion, you'll need to init the singleton object:

```swift
import struct xenon_view_sdk.Xenon

// start by initializing Xenon View
Xenon.init("<API KEY>")
```
Of course, you'll have to make the following modifications to the above code:
- Replace `<API KEY>` with your [api key](https://xenonview.com/api-get)

### Platforming
After you have initialized View, you can optionally specify platform details such as:
- Operating System version (iOS)
- Device model (iPhone, iPad, etc.)
- Software version of your application.

```javascript
import Xenon from 'xenon_view_sdk';

const softwareVersion = "5.1.5";
const deviceModel = "Pixel 4 XL";
const operatingSystemVersion = "Android 12.0";

// you can add platform details to outcomes
Xenon.platform(softwareVersion, deviceModel, operatingSystemVersion);
```
This adds platform details for each [outcome](#outcome). Typically, this would be set once at initialization:
```javascript
import Xenon from 'xenon_view_sdk';

Xenon.init('<API KEY>');
const softwareVersion = "5.1.5";
const deviceModel = "Pixel 4 XL";
const operatingSystemVersion = "Android 12.0";
Xenon.platform(softwareVersion, deviceModel, operatingSystemVersion);
```


### Add Journeys
After you have initialized the View singleton, you can start collecting journeys.

There are a few helper methods you can use:
#### <a name="outcome"></a>
#### Outcome
You can use this method to add an outcome to the journey.

```javascript
import Xenon from 'xenon_view_sdk';

// you can add an outcome to journey
let outcome = "<outcome>";
let action = "<custom action>";
Xenon.outcome(outcome, action);
```
This adds an outcome to the journey chain effectively completing it.


#### Page view
You can use this method to add page views to the journey.

```javascript
import Xenon from 'xenon_view_sdk';

// you can add a page view to a journey
let page = "test/page";
it('then adds a page view to journey', () => {
  Xenon.pageView(page);
});
```
This adds a page view step to the journey chain.


#### Funnel Stage
You can use this method to track funnel stages in the journey.

```javascript
import Xenon from 'xenon_view_sdk';

// you can add a funnel stage to a journey
let stage = "<stage in funnel>";
let action = "<custom action>";
Xenon.funnel(stage, action);
```
This adds a funnel stage to the journey chain.


#### Generic events
You can use this method to add generic events to the journey.

```javascript
import Xenon from 'xenon_view_sdk';

// you can add a generic event to journey
let event = {category: 'Event', action: 'test'};
Xenon.event(event);
```
This adds an event step to the journey chain.

### Committing Journeys

Journeys only exist locally until you commit them to the Xenon View system. After you have created and added to a journey, you can commit the journey to Xenon View for analysis as follows:
```javascript
import Xenon from 'xenon_view_sdk';

// you can commit a journey to Xenon View
await Xenon.commit();
```
This commits a journey to Xenon View for analysis.

### Deanonymizing Journeys

Xenon View supports both anonymous and known journeys. By deanonymizing a journey you can compare a user's path to other known paths and gather insights into their progress. This is optional.
```javascript
import Xenon from 'xenon_view_sdk';

// you can deanonymize before or after you have committed journey (in this case after):
let person = {name:'JS Test', email:'jstest@example.com'};
await Xenon.deanonymize(person);

// you can also deanonymize with a user ID:
let person = {
  UUID: '<some unique ID>'
}
await Xenon.deanonymize(person);
```
This deanonymizes every journey committed to a particular user.

> **Note:** With journeys that span multiple platforms (eg. Website->Android->API backend), you can merge the journeys by deanonymizing on each platform.


### Journey IDs
Each Journey has an ID akin to a session. After an Outcome occurs the ID remains the same to link all the Journeys. If you have a previous Journey in progress and would like to append to that, you can set the ID.

>**Note:** For JavaScript, the Journey ID is a session persistent variable. If a previous browser session was created, the Journey ID will be reused.


After you have initialized the Xenon singleton, you can:
1. Use the default UUID
2. Set the Journey (Session) ID
3. Regenerate a new UUID

```javascript
import Xenon from 'xenon_view_sdk';
// by default has Journey id
expect(Xenon.id()).not.toBeNull();
expect(Xenon.id()).not.toEqual('');

// you can also set the id
let testId = '<some random uuid>';
Xenon.id(testId);
expect(Xenon.id()).toEqual(testId);

// lastly you can generate a new one (useful for serialized async operations that are for different customers)
Xenon.newId();
expect(Xenon.id()).not.toBeNull();
expect(Xenon.id()).not.toEqual('');
```


### Error handling
In the event of an API error when committing, the method returns a [promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise).

> **Note:** The default handling of this situation will restore the journey (appending newly added pageViews, events, etc.) for future committing. If you want to do something special, you can do so like this:

```javascript
import Xenon from 'xenon_view_sdk';

// you can handle errors if necessary
Xenon.commit().catch(
(err) =>{
  // handle error
});
```

## <a name="license"></a>
## License

Apache Version 2.0

See [LICENSE](https://github.com/xenonview-com/view-swift-sdk/blob/main/LICENSE)

