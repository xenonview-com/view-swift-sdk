# xenon-view-sdk
The Xenon View Swift SDK is the Swift SDK to interact with [XenonView](https://xenonview.com).

**Table of contents:** <a id="contents"></a>

* [What"s New](#whats-new)
* [Introduction](#intro)
* [Steps To Get Started](#getting-started)
  * [Identify Business Outcomes](#step-1)
  * [Identify Customer Journey Milestones](#step-2)
  * [Enumerate Technical Stack](#step-3)
  * [Installation](#step-4)
  * [Instrument Business Outcomes](#step-5)
  * [Instrument Customer Journey Milestones](#step-6)
  * [Determine Commit Points](#step-7)
  * [(Optional) Group Customer Journeys](#step-8)
  * [Analysis](#step-9)
  * [Perform Experiments](#step-10)
* [Detailed Usage](#detailed-usage)
  * [Installation](#installation)
  * [Initialization](#instantiation)
  * [Service/Subscription/SaaS Business Outcomes](#saas)
  * [Ecommerce Business Outcomes](#ecom)
  * [Customer Journey Milestones](#milestones)
    * [Features Usage](#feature-usage)
    * [Content Interaction](#content-interaction)
  * [Commit Points](#commiting)
  * [Heartbeats](#heartbeat)
  * [Platforming](#platforming)
  * [Tagging](#tagging)
  * [Customer Journey Grouping](#deanonymizing-journeys)
  * [Other Considerations](#other)
    * [(Optional) Error Handling](#errors)
    * [(Optional) Custom Customer Journey Milestones](#custom)
    * [(Optional) Journey Identification](#cuuid)
* [License](#license)

<br/>

## What"s New <a id="whats-new"></a>
* v0.1.0 - SDK redesign

<br/>


## Introduction <a id="intro"></a>
Everyone should have access to world-class customer telemetry.

You should be able to identify the most pressing problems affecting your business quickly.
You should be able to determine if messaging or pricing, or technical challenges are causing friction for your customers.
You should be able to answer questions like:
1. Is my paywall wording or the price of my subscriptions causing my customers to subscribe less?
2. Is my website performance or my application performance driving retention?
3. Is purchasing a specific product or the product portfolio driving referrals?

With the correct approach to instrumentation coupled with AI-enhanced analytics, you can quickly answer these questions and much more.

<br/>

[back to top](#contents)

## Get Started With The Following Steps: <a id="getting-started"></a>
The Xenon View SDK can be used in your application to provide a new level of customer telemetry. You"ll need to embed the instrumentation into your website/application via this SDK.

Instrumentation will vary based on your use case; are you offering a service/subscription (SaaS) or selling products (Ecom)?

In a nutshell, the steps to get started are as follows:
1. Identify Business Outcomes and Customer Journey Milestones leading to those Outcomes.
2. Instrument the Outcomes/Milestones.
3. Analyze the results.

<br/>


### Step 1 - Business Outcomes <a id="step-1"></a>

Regardless of your business model, your first step will be identifying your desired business outcomes.

**Example - Service/Subscription/SaaS**:
1. Lead Capture
2. Account Signup
3. Initial Subscription
4. Renewed Subscription
5. Upsold Subscription
6. Referral

**Example - Ecom**:
1. Place the product in the cart
2. Checkout
3. Upsold
4. Purchase

> :memo: Note: Each outcome has an associated success and failure.

<br/>


### Step 2 - Customer Journey Milestones <a id="step-2"></a>

For each Business Outcome, identify potential customer journey milestones leading up to that business outcome.

**Example - Service/Subscription/SaaS for _Lead Capture_**:
1. View informational content
2. Asks question in the forum
3. Views FAQs
4. Views HowTo
5. Requests info product

**Example - Ecom for _Place product in cart_** :
1. Search for product information
2. Learns about product
3. Read reviews

<br/>

### Step 3 - Enumerate Technical Stack <a id="step-3"></a>

Next, you will want to figure out which SDK to use. We have some of the most popular languages covered.

Start by listing the technologies involved and what languages your company uses. For example:
1. Front end - UI (Javascript - react)
2. Back end - API server (Java)
3. Mobile app - iPhone (Swift)
4. Mobile app - Android (Android Java)

Next, figure out how your outcomes spread across those technologies. Below are pointers to our currently supported languages:
* [React](https://github.com/xenonview-com/view-js-sdk)
* [Angular](https://github.com/xenonview-com/view-js-sdk)
* [HTML](https://github.com/xenonview-com/view-js-sdk)
* [Plain JavaScript](https://github.com/xenonview-com/view-js-sdk)
* [iPhone/iPad](https://github.com/xenonview-com/view-swift-sdk)
* [Mac](https://github.com/xenonview-com/view-swift-sdk)
* [Java](https://github.com/xenonview-com/view-java-sdk)
* [Android Java](https://github.com/xenonview-com/view-java-sdk)
* [Python](https://github.com/xenonview-com/view-python-sdk)

Finally, continue the steps below for each technology and outcome.


### Step 4 - Installation <a id="step-4"></a>

After you have done the prework of [Step 1](#step-1) and [Step 2](#step-2), you are ready to [install Xenon View](#installation).
Once installed, you"ll need to [initialize the SDK](#instantiation) and get started instrumenting.


<br/>
<br/>


### Step 5 - Instrument Business Outcomes <a id="step-5"></a>

We have provided several SDK calls to shortcut your instrumentation and map to the outcomes identified in [Step 1](#step-1).  
These calls will roll up into the associated Categories during analysis. These rollups allow you to view each Category in totality.
As you view the categories, you can quickly identify issues (for example, if there are more Failures than Successes for a Category).

**[Service/Subscription/SaaS Related Outcome Calls](#saas)**  (click on a call to see usage)

| Category | Success | Failure | 
| --- | --- | --- |
| Lead Capture | [`leadCaptured()`](#saas-lead-capture) | [`leadCaptureDeclined()`](#saas-lead-capture-fail) | 
| Account Signup | [`accountSignup()`](#saas-account-signup) | [`accountSignupDeclined()`](#saas-account-signup-fail) | 
| Application Installation | [`applicationInstalled()`](#saas-application-install) |  [`applicationNotInstalled()`](#saas-application-install-fail) | 
| Initial Subscription | [`initialSubscription()`](#saas-initial-subscription) | [`subscriptionDeclined()`](#saas-initial-subscription-fail) |
| Subscription Renewed | [`subscriptionRenewed()`](#saas-renewed-subscription) | [`subscriptionCanceled()`](#saas-renewed-subscription-fail) | 
| Subscription Upsell | [`subscriptionUpsold()`](#saas-upsell-subscription) | [`subscriptionUpsellDeclined()`](#saas-upsell-subscription-fail) | 
| Referral | [`referral()`](#saas-referral) | [`referralDeclined()`](#saas-referral-fail) | 


**[Ecom Related Outcome Calls](#ecom)** (click on a call to see usage)

| Category | Success | Failure |
| --- | --- | --- | 
| Lead Capture | [`leadCaptured()`](#ecom-lead-capture) | [`leadCaptureDeclined()`](#ecom-lead-capture-fail) | 
| Account Signup | [`accountSignup()`](#ecom-account-signup) | [`accountSignupDeclined()`](#ecom-account-signup-fail) | 
| Add To Cart | [`productAddedToCart()`](#ecom-product-to-cart) | [`productNotAddedToCart()`](#ecom-product-to-cart-fail) |
| Product Upsell | [`upsold()`](#ecom-upsell) | [`upsellDismissed()`](#ecom-upsell-fail) | 
| Checkout | [`checkedOut()`](#ecom-checkout) | [`checkoutCanceled()`](#ecom-checkout-fail)/[`productRemoved()`](#ecom-checkout-remove) | 
| Purchase | [`purchased()`](#ecom-purchase) | [`purchaseCanceled()`](#ecom-purchase-fail) | 
| Promise Fulfillment | [`promiseFulfilled()`](#ecom-promise-fulfillment) | [`promiseUnfulfilled()`](#ecom-promise-fulfillment-fail) | 
| Product Disposition | [`productKept()`](#ecom-product-outcome) | [`productReturned()`](#ecom-product-outcome-fail) |
| Referral | [`referral()`](#ecom-referral) | [`referralDeclined()`](#ecom-referral-fail) |

<br/>

### Step 6 - Instrument Customer Journey Milestones <a id="step-6"></a>

Next, you will want to instrument your website/application/backend/service for the identified Customer Journey Milestones [Step 2](#step-2).
We have provided several SDK calls to shortcut your instrumentation here as well.  

During analysis, each Milestone is chained together with the proceeding and following Milestones.
That chain terminates with an Outcome (described in [Step 4](#step-4)).
AI/ML is employed to determine Outcome correlation and predictability for the chains and individual Milestones.
During the [analysis step](#step-8), you can view the correlation and predictability as well as the Milestone chains
(called Customer Journeys in this guide).

Milestones break down into two types (click on a call to see usage):

| Features | Content |
| --- | --- |
| [`featureAttempted()`](#feature-started) | [`contentViewed()`](#content-viewed) |
| [`featureFailed()`](#feature-failed) | [`contentEdited()`](#content-edited) |
| [`featureCompleted()`](#feature-complete) | [`contentCreated()`](#content-created) |
| | [`contentDeleted()`](#content-deleted) |
| | [`contentRequested()`](#content-requested)|
| | [`contentSearched()`](#content-searched)|

<br/>

### Step 7 - Commit Points <a id="step-7"></a>


Once instrumented, you"ll want to select appropriate [commit points](#commit). Committing will initiate the analysis on your behalf by Xenon View.

<br/>
<br/>

### Step 8 (Optional) - Group Customer Journeys <a id="step-8"></a>

All the customer journeys (milestones and outcomes) are anonymous by default.
For example, if a Customer interacts with your brand in the following way:
1. Starts on your marketing website.
2. Downloads and uses an app.
3. Uses a feature requiring an API call.


*Each of those journeys will be unconnected and not grouped.*

To associate those journeys with each other, you can [deanonymize](#deanonymizing-journeys) the Customer. Deanonymizing will allow for a deeper analysis of a particular user.

Deanonymizing is optional. Basic matching of the customer journey with outcomes is valuable by itself. Deanonymizing will add increased insight as it connects Customer Journeys across devices.

<br/>

### Step 9 - Analysis <a id="step-9"></a>


Once you have released your instrumented code, you can head to [XenonView](https://xenonview.com/) to view the analytics.

<br/>

### Step 10 - Perform Experiments <a id="step-10"></a>

There are multiple ways you can experiment using XenonView. We"ll focus here on three of the most common: time, platform, and tag based cohorts.

#### Time-based cohorts
Each Outcome and Milestone is timestamped. You can use this during the analysis phase to compare timeframes. A typical example is making a feature change.
Knowing when the feature went to production, you can filter in the XenonView UI based on the timeframe before and the timeframe after to observe the results.

#### Tag-based cohorts
You can [tag](#tagging) any journey collection before collecting data. This will allow you to run A/B testing-type experiments (of course not limited to two).
As an example, let"s say you have two alternate content/feature flows and you have a way to direct half of the users to Flow A and the other half to Flow B.
You can tag each flow before the section of code that performs that flow. After collecting the data, you can filter in the XenonView UI based on each tag to
observe the results.

#### Platform-based cohorts
You can [Platform](#platforming) any journey collection before collecting data. This will allow you to experiment against different platforms:
* Operating System Name
* Operating System version
* Device model (Pixel, iPhone 14, Docker Container, Linux VM, Dell Server, etc.)
* A software version of your application.

As an example, let"s say you have an iPhone and Android mobile application and you want to see if an outcome is more successful on one device verse the other.
You can platform before the section of code that performs that flow. After collecting the data, you can filter in the XenonView UI based on each platform to
observe the results.

<br/>
<br/>
<br/>

[back to top](#contents)

## Detailed Usage <a id="detailed-usage"></a>
The following section gives detailed usage instructions and descriptions.
It provides code examples for each of the calls.

<br/>

### Installation <a id="installation"></a>

<br/>

You can install the Xenon View SDK from [Github](https://github.com/xenonview-com/view-swift-sdk):

#### Via Swift Package Manager

Add to your dependencies section:
```swift
dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url:"https://github.com/xenonview-com/view-swift-sdk", from: "0.1.0"),
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

#### Via Xcode (per version 14)

1) Right-click on your top-level project and select ```Add Packages...```:

![Image](./documentation/right_click_to_add.png)


2) Paste into the search bar ```https://github.com/xenonview-com/view-swift-sdk``` and click ```Add Package```:

![Image](./documentation/paste_url.png)


3) Select ```xenon_view_sdk``` and click ```Add Package```:

![Image](./documentation/select_xenon_view.png)


4) Ensure Xenon SDK is installed by viewing ```Package Dependencies```:

![Image](./documentation/installed_success.png)



<br/>

[back to top](#contents)

### Instantiation <a id="instantiation"></a>

The View SDK is a Swift package you"ll need to include in your application. After inclusion, you"ll need to init the singleton object:

```swift
import xenon_view_sdk

// start by initializing Xenon View
Xenon().initialize(apiKey:"<API KEY>")
```

Typically, this would be done during app initialization:
```swift 
import xenon_view_sdk

@main
struct ExampleApp: App {
    // register initial Xenon parameters every launch
    init() {
        // start by initializing Xenon View
        Xenon().initialize(apiKey:"<API KEY>")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Of course, you"ll have to make the following modifications to the above code:
- Replace `<API KEY>` with your [api key](https://xenonview.com/api-get)

> **Note:** For older OS support, surround your calls with: 

```swift
if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
    Xenon().initialize(apiKey:"<API KEY>")
}
```

<br/>

[back to top](#contents)

### Service/Subscription/SaaS Related Business Outcomes <a id="saas"></a>

<br/>

#### Lead Capture  <a id="saas-lead-capture"></a>
Use this call to track Lead Capture (emails, phone numbers, etc.)
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```leadCaptured()```
```swift
import xenon_view_sdk

let emailSpecified = "Email"
let phoneSpecified = "Phone Number"

// Successful Lead Capture of an email
try! Xenon().leadCaptured(specifier: emailSpecified)
//...
// Successful Lead Capture of a phone number
try! Xenon().leadCaptured(specifier: phoneSpecified)
```

<br/>

##### ```leadCaptureDeclined()``` <a id="saas-lead-capture-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers
```swift
import xenon_view_sdk

let emailSpecified = "Email"
let phoneSpecified = "Phone Number"

// Unsuccessful Lead Capture of an email
try! Xenon().leadCaptureDeclined(specifier: emailSpecified)
// ...
// Unsuccessful Lead Capture of a phone number
try! Xenon().leadCaptureDeclined(specifier: phoneSpecified)
```

<br/>

#### Account Signup  <a id="saas-account-signup"></a>
Use this call to track when customers signup for an account.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```accountSignup()```
```swift
import xenon_view_sdk

let Facebook = "Facebook"
let Google = "Facebook"
let Email = "Email"

// Successful Account Signup with Facebook
try! Xenon().accountSignup(specifier: Facebook)
// ...
// Successful Account Signup with Google
try! Xenon().accountSignup(specifier: Google)
// ...
// Successful Account Signup with an Email
try! Xenon().accountSignup(specifier: Email)
```

<br/>

##### ```accountSignupDeclined()``` <a id="saas-account-signup-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers
```swift
import xenon_view_sdk

let Facebook = "Facebook"
let Google = "Facebook"
let Email = "Email"

// Unsuccessful Account Signup with Facebook
try! Xenon().accountSignupDeclined(specifier: Facebook)
// ...
// Unsuccessful Account Signup with Google
try! Xenon().accountSignupDeclined(specifier: Google)
// ...
// Unsuccessful Account Signup with an Email
try! Xenon().accountSignupDeclined(specifier: Email)
```

<br/>

#### Application Installation  <a id="saas-application-install"></a>
Use this call to track when customers install your application.

<br/>

##### ```applicationInstalled()```
```swift
import xenon_view_sdk

// Successful Application Installation
try! Xenon().applicationInstalled()
```

<br/>

##### ```applicationNotInstalled()``` <a id="saas-application-install-fail"></a>
> :memo: Note: You want consistency between success and failure.
```swift
import xenon_view_sdk

// Unsuccessful or not completed Application Installation
try! Xenon().applicationNotInstalled()
```

<br/>

#### Initial Subscription  <a id="saas-initial-subscription"></a>
Use this call to track when customers initially subscribe.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```initialSubscription()```
```swift
import xenon_view_sdk

let Silver = "Silver Monthly"
let Gold = "Gold"
let Platium = "Platium"
let annualSilver = "Silver Annual"
let method = "Stripe" // optional

// Successful subscription of the lowest tier with Stripe
try! Xenon().initialSubscription(tier: Silver, method: method)
// ...
// Successful subscription of the middle tier
try! Xenon().initialSubscription(tier: Gold)
// ...
// Successful subscription to the top tier
try! Xenon().initialSubscription(tier: Platium)
// ...
// Successful subscription of an annual period
try! Xenon().initialSubscription(tier: annualSilver)
```

<br/>

##### ```subscriptionDeclined()``` <a id="saas-initial-subscription-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers
```swift
import xenon_view_sdk

let Silver = "Silver Monthly"
let Gold = "Gold"
let Platium = "Platium"
let annualSilver = "Silver Annual"
let method = "Stripe" // optional

// Unsuccessful subscription of the lowest tier
try! Xenon().subscriptionDeclined(tier: Silver)
// ...
// Unsuccessful subscription of the middle tier
try! Xenon().subscriptionDeclined(tier: Gold)
// ...
// Unsuccessful subscription to the top tier
try! Xenon().subscriptionDeclined(tier: Platium)
// ...
// Unsuccessful subscription of an annual period
try! Xenon().subscriptionDeclined(tier: annualSilver, method: method)
```

<br/>

#### Subscription Renewal  <a id="saas-renewed-subscription"></a>
Use this call to track when customers renew.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```subscriptionRenewed()```
```swift
import xenon_view_sdk

let Silver = "Silver Monthly"
let Gold = "Gold"
let Platium = "Platium"
let annualSilver = "Silver Annual"
let method = "Stripe" //optional

// Successful renewal of the lowest tier with Stripe
try! Xenon().subscriptionRenewed(tier: Silver, method: method)
// ...
// Successful renewal of the middle tier
try! Xenon().subscriptionRenewed(tier: Gold)
// ...
// Successful renewal of the top tier
try! Xenon().subscriptionRenewed(tier: Platium)
// ...
// Successful renewal of an annual period
try! Xenon().subscriptionRenewed(tier: annualSilver)
```


<br/>

##### ```subscriptionCanceled()``` <a id="saas-renewed-subscription-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers

```swift
import xenon_view_sdk

let tierSilver = "Silver Monthly"
let tierGold = "Gold"
let tierPlatium = "Platium"
let annualSilver = "Silver Annual"
let method = "Stripe" //optional

// Canceled subscription of the lowest tier
try! Xenon().subscriptionCanceled(tier: Silver)
// ...
// Canceled subscription of the middle tier
try! Xenon().subscriptionCanceled(tier: Gold)
// ...
// Canceled subscription of the top tier
try! Xenon().subscriptionCanceled(tier: Platium)
// ...
// Canceled subscription of an annual period with Stripe
try! Xenon().subscriptionCanceled(tier: annualSilver, method: method)
```

<br/>

#### Subscription Upsold  <a id="saas-upsell-subscription"></a>
Use this call to track when a Customer upgrades their subscription.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```subscriptionUpsold()```

```swift
import xenon_view_sdk

let Gold = "Gold Monthly"
let Platium = "Platium"
let annualGold = "Gold Annual"
let method = "Stripe" // optional

// Assume already subscribed to Silver

// Successful upsell of the middle tier with Stripe
try! Xenon().subscriptionUpsold(tier: Gold, method: method)
// ...
// Successful upsell of the top tier
try! Xenon().subscriptionUpsold(tier: Platium)
// ...
// Successful upsell of middle tier - annual period
try! Xenon().subscriptionUpsold(tier: annualGold)
```

<br/>

##### ```subscriptionUpsellDeclined()``` <a id="saas-upsell-subscription-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers

```swift
import xenon_view_sdk

let Gold = "Gold Monthly"
let Platium = "Platium"
let annualGold = "Gold Annual"
let method = "Stripe" //optional

// Assume already subscribed to Silver

// Rejected upsell of the middle tier
try! Xenon().subscriptionUpsellDeclined(tier: Gold)
// ...
// Rejected upsell of the top tier
try! Xenon().subscriptionUpsellDeclined(tier: Platium)
// ...
// Rejected upsell of middle tier - annual period with Stripe
try! Xenon().subscriptionUpsellDeclined(tier: annualGold, method: method)
```

<br/>

#### Referrals  <a id="saas-referral"></a>
Use this call to track when customers refer someone to your offering.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```referral()```

```swift
import xenon_view_sdk

let kind = "Share"
let detail = "Review" // optional

// Successful referral by sharing a review
try! Xenon().referral(kind: kind, detail: detail)
// -OR-
try! Xenon().referral(kind: kind)
```

<br/>

##### ```referralDeclined()``` <a id="saas-referral-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers

```swift
import xenon_view_sdk

let kind = "Share"
let detail = "Review" // optional

//Customer declined referral
try! Xenon().referralDeclined(kind: kind, detail: detail)
// -OR-
try! Xenon().referralDeclined(kind: kind)
```

<br/>

[back to top](#contents)

### Ecommerce Related Outcomes <a id="ecom"></a>


<br/>

#### Lead Capture  <a id="ecom-lead-capture"></a>
Use this call to track Lead Capture (emails, phone numbers, etc.)
You can add a specifier string to the call to differentiate as follows:


<br/>

##### ```leadCaptured()```
```swift
import xenon_view_sdk

let emailSpecified = "Email"
let phoneSpecified = "Phone Number"

// Successful Lead Capture of an email
try! Xenon().leadCaptured(specifier: emailSpecified)
//...
// Successful Lead Capture of a phone number
try! Xenon().leadCaptured(specifier: phoneSpecified)
```

<br/>

##### ```leadCaptureDeclined()``` <a id="saas-lead-capture-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers
```swift
import xenon_view_sdk

let emailSpecified = "Email"
let phoneSpecified = "Phone Number"

// Unsuccessful Lead Capture of an email
try! Xenon().leadCaptureDeclined(specifier: emailSpecified)
// ...
// Unsuccessful Lead Capture of a phone number
try! Xenon().leadCaptureDeclined(specifier: phoneSpecified)
```

<br/>

#### Account Signup  <a id="ecom-account-signup"></a>
Use this call to track when customers signup for an account.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```accountSignup()```
```swift
import xenon_view_sdk

let Facebook = "Facebook"
let Google = "Facebook"
let Email = "Email"

// Successful Account Signup with Facebook
try! Xenon().accountSignup(specifier: Facebook)
// ...
// Successful Account Signup with Google
try! Xenon().accountSignup(specifier: Google)
// ...
// Successful Account Signup with an Email
try! Xenon().accountSignup(specifier: Email)
```

<br/>

##### ```accountSignupDeclined()``` <a id="saas-account-signup-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers
```swift
import xenon_view_sdk

let Facebook = "Facebook"
let Google = "Facebook"
let Email = "Email"

// Unsuccessful Account Signup with Facebook
try! Xenon().accountSignupDeclined(specifier: Facebook)
// ...
// Unsuccessful Account Signup with Google
try! Xenon().accountSignupDeclined(specifier: Google)
// ...
// Unsuccessful Account Signup with an Email
try! Xenon().accountSignupDeclined(specifier: Email)
```

<br/>

#### Add Product To Cart  <a id="ecom-product-to-cart"></a>
Use this call to track when customers add a product to the cart.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```productAddedToCart()```

```swift
import xenon_view_sdk

let laptop = "Dell XPS"
let keyboard = "Apple Magic Keyboard"

// Successful adds a laptop to the cart
try! Xenon().productAddedToCart(product: laptop)
// ...
// Successful adds a keyboard to the cart
try! Xenon().productAddedToCart(keyboard)
```

<br/>

##### ```productNotAddedToCart()``` <a id="ecom-product-to-cart-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers

```swift
import xenon_view_sdk

let laptop = "Dell XPS"
let keyboard = "Apple Magic Keyboard"

// Doesn"t add a laptop to the cart
try! Xenon().productNotAddedToCart(product: laptop)
// ...
// Doesn"t add a keyboard to the cart
try! Xenon().productNotAddedToCart(product: keyboard)
```

<br/>

#### Upsold Additional Products  <a id="ecom-upsell"></a>
Use this call to track when you upsell additional product(s) to customers.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```upsold()```

```swift
import xenon_view_sdk

let laptop = "Dell XPS"
let keyboard = "Apple Magic Keyboard"

// upsold a laptop
try! Xenon().upsold(product: laptop)
// ...
// upsold a keyboard
try! Xenon().upsold(product: keyboard)
```

<br/>

##### ```upsellDismissed()``` <a id="ecom-upsell-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers

```swift
import xenon_view_sdk

let laptop = "Dell XPS"
let keyboard = "Apple Magic Keyboard"

// Doesn"t add a laptop during upsell
try! Xenon().upsellDismissed(product: laptop)
// ...
// Doesn"t add a keyboard during upsell
try! Xenon().upsellDismissed(product: keyboard)
```

<br/>

#### Customer Checks Out  <a id="ecom-checkout"></a>
Use this call to track when your Customer is checking out.

<br/>

##### ```checkedOut()```

```swift
import xenon_view_sdk

// Successful Checkout
try! Xenon().checkedOut()
```

<br/>

##### ```checkoutCanceled()``` <a id="ecom-checkout-fail"></a>

```swift
import xenon_view_sdk

//Customer cancels check out.
try! Xenon().checkoutCanceled()

```

<br/>

##### ```productRemoved()``` <a id="ecom-checkout-remove"></a>

```swift
import xenon_view_sdk

let laptop = "Dell XPS"
let keyboard = "Apple Magic Keyboard"

// Removes a laptop during checkout
try! Xenon().productRemoved(product: laptop)
// ...
// Removes a keyboard during checkout
try! Xenon().productRemoved(product: keyboard)
```

<br/>

#### Customer Completes Purchase  <a id="ecom-purchase"></a>
Use this call to track when your Customer completes a purchase.

<br/>

##### ```purchased()```

```swift
import xenon_view_sdk

let method = "Stripe"

// Successful Purchase
try! Xenon().purchased(method: method)
```

<br/>

##### ```purchaseCanceled()``` <a id="ecom-purchase-fail"></a>

```swift
import xenon_view_sdk

let method = "Stripe" // optional

//Customer cancels the purchase.
try! Xenon().purchaseCanceled()
// -OR-
try! Xenon().purchaseCanceled(method: method)

```

<br/>

#### Purchase Shipping  <a id="ecom-promise-fulfillment"></a>
Use this call to track when your Customer receives a purchase.

<br/>

##### ```promiseFulfilled()```

```swift
import xenon_view_sdk

// Successfully Delivered Purchase
try! Xenon().promiseFulfilled()
```


<br/>

##### ```promiseUnfulfilled(()``` <a id="ecom-promise-fulfillment-fail"></a>

```swift
import xenon_view_sdk

// Problem Occurs During Shipping And No Delivery
try! Xenon().promiseUnfulfilled()
```

<br/>

#### Customer Keeps or Returns Product  <a id="ecom-product-outcome"></a>
Use this call to track if your Customer keeps the product.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```productKept()```

```swift
import xenon_view_sdk

let laptop = "Dell XPS"
let keyboard = "Apple Magic Keyboard"

//Customer keeps a laptop
try! Xenon().productKept(product: laptop)
// ...
//Customer keeps a keyboard
try! Xenon().productKept(product: keyboard)
```

<br/>

##### ```productReturned()``` <a id="ecom-product-outcome-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers

```swift
import xenon_view_sdk

let laptop = "Dell XPS"
let keyboard = "Apple Magic Keyboard"

//Customer returns a laptop
try! Xenon().productReturned(product: laptop)
// ...
//Customer returns a keyboard
try! Xenon().productReturned(product: keyboard)
```

<br/>

#### Referrals  <a id="ecom-referral"></a>
Use this call to track when customers refer someone to your offering.
You can add a specifier string to the call to differentiate as follows:

<br/>

##### ```referral()```

```swift
import xenon_view_sdk

let kind = "Share"
let detail = "Review" // optional

// Successful referral by sharing a review
try! Xenon().referral(kind: kind, detail: detail)
// -OR-
try! Xenon().referral(kind: kind)
```

<br/>

##### ```referralDeclined()``` <a id="saas-referral-fail"></a>
> :memo: Note: You want to be consistent between success and failure and match the specifiers

```swift
import xenon_view_sdk

let kind = "Share"
let detail = "Review" // optional

//Customer declined referral
try! Xenon().referralDeclined(kind: kind, detail: detail)
// -OR-
try! Xenon().referralDeclined(kind: kind)
```

<br/>

[back to top](#contents)

### Customer Journey Milestones <a id="milestones"></a>

As a customer interacts with your brand (via Advertisements, Marketing Website, Product/Service, etc.), they journey through a hierarchy of interactions.
At the top level are business outcomes. In between Outcomes, they may achieve other milestones, such as interacting with content and features.
Proper instrumentation of these milestones can establish correlation and predictability of business outcomes.

As of right now, Customer Journey Milestones break down into two categories:
1. [Feature Usage](#feature-usage)
2. [Content Interaction](#content-interaction)

<br/>

#### Feature Usage  <a id="feature-usage"></a>
Features are your product/application/service"s traits or attributes that deliver value to your customers.
They differentiate your offering in the market. Typically, they are made up of and implemented by functions.

<br/>

##### ```featureAttempted()``` <a id="feature-started"></a>
Use this function to indicate the start of feature usage.

```swift
import xenon_view_sdk

let name = "Scale Recipe"
let detail = "x2" // optional

//Customer initiated using a feature
try! Xenon().featureAttempted(feature: name, detail: detail)
// -OR-
try! Xenon().featureAttempted(feature: name)
```

<br/>

##### ```featureCompleted()``` <a id="feature-complete"></a>
Use this function to indicate the successful completion of the feature.

```swift
import xenon_view_sdk

let name = "Scale Recipe"
let detail = "x2" // optional

// ...
// Customer used a feature
try! Xenon().featureCompleted(feature: name, detail: detail)

// -OR-

// Customer initiated using a feature
try! Xenon().featureAttempted(feature: name, detail: detail)
// ...
// feature code/function calls
// ...
// feature completes successfully
try! Xenon().featureCompleted(feature: name, detail: detail)
// -OR-
try! Xenon().featureCompleted(feature: name)
```

<br/>

##### ```featureFailed()``` <a id="feature-failed"></a>
Use this function to indicate the unsuccessful completion of a feature being used (often in the exception handler).

```swift
import xenon_view_sdk


let name = "Scale Recipe"
let detail = "x2" // optional


//Customer initiated using a feature
try! Xenon().featureAttempted(feature: name, detail: detail)
try {
  // feature code that could fail
}
catch(err) {
  //feature completes unsuccessfully
  try! Xenon().featureFailed(feature: name, detail: detail)
  // -OR-
  try! Xenon().featureFailed(feature: name)
}

```

<br/>

[back to top](#contents)

#### Content Interaction  <a id="content-interaction"></a>
Content is created assets/resources for your site/service/product.
It can be static or dynamic. You will want to mark content that contributes to your Customer"s experience or buying decision.
Typical examples:
* Blog
* Blog posts
* Video assets
* Comments
* Reviews
* HowTo Guides
* Charts/Graphs
* Product/Service Descriptions
* Surveys
* Informational product

<br/>

##### ```contentViewed()``` <a id="content-viewed"></a>
Use this function to indicate a view of specific content.

```swift
import xenon_view_sdk

let contentType = "Blog Post"
let identifier = "how-to-install-xenon-view" // optional

// Customer view a blog post
try! Xenon().contentViewed(type: contentType, identifier: identifier)
// -OR-
try! Xenon().contentViewed(type: contentType)
```

<br/>

##### ```contentEdited()``` <a id="content-edited"></a>
Use this function to indicate the editing of specific content.

```swift
import xenon_view_sdk

let contentType = "Review"
let identifier = "Dell XPS" //optional
let detail = "Rewrote" //optional

//Customer edited their review about a laptop
try! Xenon().contentEdited(type: contentType, identifier: identifier, detail: detail)
// -OR-
try! Xenon().contentEdited(type: contentType, identifier: identifier)
// -OR-
try! Xenon().contentEdited(type: contentType)
```

<br/>

##### ```contentCreated()``` <a id="content-created"></a>
Use this function to indicate the creation of specific content.

```swift
import xenon_view_sdk

let contentType = "Blog Comment"
let identifier = "how-to-install-xenon-view" // optional

//Customer wrote a comment on a blog post
try! Xenon().contentCreated(type: contentType, identifier: identifier)
// -OR-
try! Xenon().contentCreated(type: contentType)
```

<br/>

##### ```contentDeleted()``` <a id="content-deleted"></a>
Use this function to indicate the deletion of specific content.

```swift
import xenon_view_sdk

let contentType = "Blog Comment"
let identifier = "how-to-install-xenon-view" // optional

//Customer deleted their comment on a blog post
try! Xenon().contentDeleted(type: contentType, identifier: identifier)
// -OR-
try! Xenon().contentDeleted(type: contentType)
```

<br/>

##### ```contentRequested()``` <a id="content-requested"></a>
Use this function to indicate the request for specific content.

```swift
import xenon_view_sdk

let contentType = "Info Product"
let identifier = "how-to-efficiently-use-google-ads" // optional

//Customer requested some content
try! Xenon().contentRequested(type: contentType, identifier: identifier)
// -OR-
try! Xenon().contentRequested(type: contentType)
```

<br/>

##### ```contentSearched()``` <a id="content-searched"></a>
Use this function to indicate when a user searches.

```swift
import xenon_view_sdk

let contentType = "Info Product"

// Customer searched for some content
try! Xenon().contentSearched(type: contentType)
```

<br/>

[back to top](#contents)

### Commit Points   <a id="commiting"></a>


Business Outcomes and Customer Journey Milestones are tracked locally in memory until you commit them to the Xenon View system.
After you have created (by either calling a milestone or outcome) a customer journey, you can commit it to Xenon View for analysis as follows:

<br/>

#### `commit()`

This call commits a customer journey to Xenon View for analysis.
```swift
import xenon_view_sdk

// you can commit a journey to Xenon View
try! Xenon().commit()
```


<br/>

[back to top](#contents)

### Heartbeats   <a id="heartbeat"></a>


Business Outcomes and Customer Journey Milestones are tracked locally in memory until you commit them to the Xenon View system.
You can use the heartbeat call if you want to commit in batch.
Additionally, the heartbeat call will update a last-seen metric for customer journeys that have yet to arrive at Business Outcome. The last-seen metric is useful when analyzing stalled Customer Journeys.

Usage is as follows:

<br/>

#### `heartbeat()`
```swift
import xenon_view_sdk

// you can heartbeat to Xenon View
try! Xenon().heartbeat()
```

This call commits any uncommitted journeys to Xenon View for analysis and updates the last accessed time.


<br/>

[back to top](#contents)

### Platforming  <a id="platforming"></a>

After you have initialized View, you can optionally specify platform details such as:
- Operating System Name 
- Operating System version (iOS) See [OperatingSystemVersion](https://developer.apple.com/documentation/foundation/operatingsystemversion)
- Device model (iPhone, iPad, etc.) See [DeviceKit](https://github.com/devicekit/DeviceKit)
- Software version of your application.

<br/>

#### `platform()`
```swift
import xenon_view_sdk

let softwareVersion = "x.y.z" // use your app version
let deviceModel = "iPhone 11 Pro"
let operatingSystemVersion = "16.0.2"
let operatingSystemName = "iOS"

// you can add platform details to outcomes
try! Xenon().platform(softwareVersion: softwareVersion, deviceModel: deviceModel, operatingSystemVersion: operatingSystemVersion)
```
This adds platform details for each [outcome](#outcome). Typically, this would be set once at initialization:
```swift
import DeviceKit
import xenon_view_sdk

@main
struct ExampleApp: App {
    // register initial Xenon parameters every launch
    init() {
        // start by initializing Xenon View
        Xenon().initialize(apiKey:"<API KEY>")
        let os = ProcessInfo().operatingSystemVersion
        let softwareVersion = "5.1.5"
        let deviceModel = "\(Device.current)"
        let operatingSystemVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        let operatingSystemName = ProcessInfo().operatingSystemVersionString

        try! try! Xenon().platform(softwareVersion: softwareVersion, deviceModel: deviceModel, operatingSystemName: operatingSystemName, operatingSystemVersion: operatingSystemVersion)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```
<br/>

[back to top](#contents)

### Tagging  <a id="tagging"></a>

After you have initialized Xenon View, you can optionally tag customer journeys.
Tagging helps when running experiments such as A/B testing.

> :memo: Note: You are not limited to just 2 (A or B) there can be many. Additionally, you can add multiple tags.

<br/>

#### `tag()`
```swift
import xenon_view_sdk

let tag = "subscription-variant-A"

// you can add platform details to outcomes
try! Xenon().tag(tags: [tag])
```
This adds tags to each outcome ([Saas](#saas)/[Ecom](#ecom)).
Typically, you would Tag once you know the active experiment for this Customer:
```swift
import xenon_view_sdk

@main
struct ExampleApp: App {
    // register initial Xenon parameters every launch
    init() {
        // start by initializing Xenon View
        Xenon().initialize(apiKey:"<API KEY>")
        let experimentTag = getExperiment()
        try! Xenon().tag(tags: [experimentTag])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

<br/>

#### `untag()`
```swift
import xenon_view_sdk

// you can clear all tags with the untag method
try! Xenon().untag()
```

<br/>

[back to top](#contents)

### Customer Journey Grouping <a id="deanonymizing-journeys"></a>


Xenon View supports both anonymous and grouped (known) journeys.

All the customer journeys (milestones and outcomes) are anonymous by default.
For example, if a Customer interacts with your brand in the following way:
1. Starts on your marketing website.
2. Downloads and uses an app.
3. Uses a feature requiring an API call.

*Each of those journeys will be unconnected and not grouped.*

To associate those journeys with each other, you can use `deanonymize()`. Deanonymizing will allow for a deeper analysis of a particular user.

Deanonymizing is optional. Basic matching of the customer journey with outcomes is valuable by itself. Deanonymizing will add increased insight as it connects Customer Journeys across devices.

Usage is as follows:

<br/>

```swift
import xenon_view_sdk

// you can deanonymize before or after you have committed journey (in this case after):
let person = [
    "name": "Test User",
    "email": "test@example.com"
]
try! await opSubject.deanonymize(person: person)

// you can also deanonymize with a user ID:
let person = [
  "UUID": "<some unique ID>"
]
try! await opSubject.deanonymize(person: person)
```

This call deanonymizes every journey committed to a particular user.

> **:memo: Note:** With journeys that span multiple platforms (e.g., Website->iPhone->API backend), you can group the Customer Journeys by deanonymizing each.


<br/>

[back to top](#contents)

### Other Operations <a id="other"></a>

There are various other operations that you might find helpful:

<br/>
<br/>

#### Error handling <a id="errors"></a>
In the event of an API error when committing, the method returns a [Task](https://developer.apple.com/documentation/swift/task).

> **Note:** The default handling of this situation will restore the journey (appending newly added pageViews, events, etc.) for future committing. If you want to do something special, you can do so like this:

```swift
import xenon_view_sdk

// you can handle errors if necessary
do {
    let result = try await opSubject.commit().value
    switch result {
    case .success(let dictionary):
        print(dictionary)
    case .failure(let error):
        //... handle server side error ...
        print(error)
    }
} catch {
    //... handle local error ...
    print(error)
}

```

<br/>

#### Custom Milestones <a id="custom"></a>

You can add custom milestones if you need more than the current Customer Journey Milestones.

<br/>

##### `milestone()`

```swift
import xenon_view_sdk

// you can add a custom milestone to the customer journey
let category = "Function"
let operation = "Called"
let name = "Query Database"
let detail = "User Lookup"
try! Xenon().milestone(category: category, operation: operation, name: name, detail: detail)
```

This call adds a custom milestone to the customer journey.

<br/>

#### Journey IDs <a id="cuuid"></a>
Each Customer Journey has an ID akin to a session.
After committing an Outcome, the ID remains the same to link all the Journeys.
If you have a previous Customer Journey in progress and would like to append to that, you can get/set the ID.

>**:memo: Note:** For JavaScript, the Journey ID is a persistent session variable.
> Therefore, subsequent Outcomes will reuse the Journey ID if the Customer had a previous browser session.


After you have initialized the Xenon singleton, you can:
1. Use the default UUID
2. Set the Customer Journey (Session) ID
3. Regenerate a new UUID
4. Retrieve the Customer Journey (Session) ID

<br/>

##### `id()`
```swift
import xenon_view_sdk
// by default has Journey id
expect(Xenon().id()).notTo(beNil())
expect(Xenon().id()).notTo(equal(""))

// you can also set the id
let testId = "<some random uuid>"
Xenon().id(_id: testId)


// lastly you can generate a new one (useful for serialized async operations that are for different customers)
Xenon().newId()
expect(Xenon().id()).notTo(beNil())
expect(Xenon().id()).notTo(equal(""))
```


<br/>

[back to top](#contents)

## License  <a name="license"></a>

Apache Version 2.0

See [LICENSE](https://github.com/xenonview-com/view-js-sdk/blob/main/LICENSE)

[back to top](#contents)


