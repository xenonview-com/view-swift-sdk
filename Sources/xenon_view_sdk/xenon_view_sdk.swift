//
// Created by Woydziak, Luke on 9/12/22.
//

import Foundation
import SwiftyJSON

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public class Xenon {
    public enum Errors: Error {
        case authenticationTokenError(String)
    }

    private var journeyApi: Api
    private var heartbeatApi: Api
    private var deanonApi: Api
    private static var _id: String = UUID().uuidString
    private static var _journey: Array<Any> = []
    private static var apiUrl: String = "https://app.xenonview.com"
    private static var apiKey: String = ""
    private static var allowSelfSigned: Bool = false
    private static var platform_: Dictionary<String, Any> = [:]
    private static var variants_: Array<Any> = []
    private var restoreJourney: Array<Any> = []

    public init() {
        journeyApi = JourneyApi()
        heartbeatApi = HeartbeatApi()
        deanonApi = DeanonymizeApi()
    }

    convenience init(apiKey: String) {
        self.init()
        Xenon.apiKey = apiKey
        Xenon.apiUrl = "https://app.xenonview.com"
    }

    convenience init(apiKey: String, _journeyApi: Api) {
        self.init(apiKey: apiKey)
        journeyApi = _journeyApi
    }

    convenience init(apiKey: String, _allowSelfSigned: Bool) {
        self.init(apiKey: apiKey)
        Xenon.allowSelfSigned = _allowSelfSigned
    }

    convenience init(apiKey: String, apiUrl: String) {
        self.init(apiKey: apiKey)
        Xenon.apiUrl = apiUrl
    }

    convenience init(apiKey: String, apiUrl: String, _allowSelfSigned: Bool) {
        self.init(apiKey: apiKey, apiUrl: apiUrl)
        Xenon.allowSelfSigned = _allowSelfSigned
    }

    convenience init(apiKey: String, apiUrl: String, _journeyApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl)
        journeyApi = _journeyApi
    }

    convenience init(_journeyApi: Api) {
        self.init()
        journeyApi = _journeyApi
    }

    convenience init(apiKey: String, apiUrl: String, _allowSelfSigned: Bool, _journeyApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl, _allowSelfSigned: _allowSelfSigned)
        journeyApi = _journeyApi
    }

    convenience init(apiKey: String, apiUrl: String, _allowSelfSigned: Bool, _journeyApi: Api, _deanonApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl, _allowSelfSigned: _allowSelfSigned, _journeyApi: _journeyApi)
        deanonApi = _deanonApi
    }

    convenience init(apiKey: String, apiUrl: String, _journeyApi: Api, _deanonApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl, _journeyApi: _journeyApi)
        deanonApi = _deanonApi
    }

    convenience init(apiKey: String, apiUrl: String, _journeyApi: Api, _deanonApi: Api, _heartbeatApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl, _journeyApi: _journeyApi, _deanonApi: _deanonApi)
        heartbeatApi = _heartbeatApi
    }

    public func initialize(apiKey: String, apiUrl: String) {
        if (apiUrl.count > 0) {
            Xenon.apiUrl = apiUrl
        }
        if (apiKey.count > 0) {
            Xenon.apiKey = apiKey
        }
    }

    public func initialize(apiKey: String) {
        initialize(apiKey: apiKey, apiUrl: "")
    }

    public func platform(softwareVersion: String, deviceModel: String, operatingSystemName: String, operatingSystemVersion: String) throws {
        Xenon.platform_ = [
            "softwareVersion": softwareVersion,
            "deviceModel": deviceModel,
            "operatingSystemName": operatingSystemName,
            "operatingSystemVersion": operatingSystemVersion
        ]
    }

    public func removePlatform() {
        Xenon.platform_ = [:]
    }

    public func variant(names: Array<String>) {
        Xenon.variants_ = names
    }

    public func resetVariants() {
        Xenon.variants_ = []
    }

    // Stock Business Outcomes:

    public func leadCaptured(specifier: String) throws {
        let content = [
            "superOutcome": "Lead Capture",
            "outcome": specifier,
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func leadCaptureDeclined(specifier: String) throws {
        let content = [
            "superOutcome": "Lead Capture",
            "outcome": specifier,
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    public func accountSignup(specifier: String) throws {
        let content = [
            "superOutcome": "Account Signup",
            "outcome": specifier,
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func accountSignupDeclined(specifier: String) throws {
        let content = [
            "superOutcome": "Account Signup",
            "outcome": specifier,
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    public func applicationInstalled() throws {
        let content = [
            "superOutcome": "Application Installation",
            "outcome": "Installed",
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func applicationNotInstalled() throws {
        let content = [
            "superOutcome": "Application Installation",
            "outcome": "Not Installed",
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    private func addMethodToContent(content: Dictionary<String, Any>, method: String)  -> Dictionary<String, Any> {
        var newContent = content
        newContent["method"] = method
        return newContent
    }
    private func addPriceToContent(content: Dictionary<String, Any>, price: String)  -> Dictionary<String, Any> {
        var newContent = content
        newContent["price"] = price
        return newContent
    }
    private func addTermToContent(content: Dictionary<String, Any>, term: String)  -> Dictionary<String, Any> {
        var newContent = content
        newContent["term"] = term
        return newContent
    }
    private func addIdToContent(content: Dictionary<String, Any>, id: String)  -> Dictionary<String, Any> {
        var newContent = content
        newContent["id"] = id
        return newContent
    }

    public func initialSubscription(tier: String, method: String, price: String, term: String) throws {
        var content = initialSubscriptionContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func initialSubscription(tier: String, method: String, price: String) throws {
        var content = initialSubscriptionContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func initialSubscription(tier: String, method: String) throws {
        var content = initialSubscriptionContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func initialSubscriptionContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Initial Subscription",
            "outcome": "Subscribe - " + tier,
            "result": "success"
        ]
    }
    public func initialSubscription(tier: String) throws {
        let content = initialSubscriptionContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func subscriptionDeclined(tier: String, method: String, price: String, term: String) throws {
        var content = subscriptionDeclinedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func subscriptionDeclined(tier: String, method: String, price: String) throws {
        var content = subscriptionDeclinedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func subscriptionDeclined(tier: String, method: String) throws {
        var content = subscriptionDeclinedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func subscriptionDeclinedContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Initial Subscription",
            "outcome": "Decline - " + tier,
            "result": "fail"
        ]
    }
    public func subscriptionDeclined(tier: String) throws {
        let content = subscriptionDeclinedContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func subscriptionRenewed(tier: String, method: String, price: String, term: String) throws {
        var content = subscriptionRenewedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func subscriptionRenewed(tier: String, method: String, price: String) throws {
        var content = subscriptionRenewedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func subscriptionRenewed(tier: String, method: String) throws {
        var content = subscriptionRenewedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func subscriptionRenewedContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Subscription Renewal",
            "outcome": "Renew - " + tier,
            "result": "success"
        ]
    }
    public func subscriptionRenewed(tier: String) throws {
        let content = subscriptionRenewedContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func subscriptionCanceled(tier: String, method: String, price: String, term: String) throws {
        var content = subscriptionCanceledContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func subscriptionCanceled(tier: String, method: String, price: String) throws {
        var content = subscriptionCanceledContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func subscriptionCanceled(tier: String, method: String) throws {
        var content = subscriptionCanceledContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func subscriptionCanceledContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Subscription Renewal",
            "outcome": "Cancel - " + tier,
            "result": "fail"
        ]
    }
    public func subscriptionCanceled(tier: String) throws {
        let content = subscriptionCanceledContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func subscriptionPaused(tier: String, method: String, price: String, term: String) throws {
        var content = subscriptionPausedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func subscriptionPaused(tier: String, method: String, price: String) throws {
        var content = subscriptionPausedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func subscriptionPaused(tier: String, method: String) throws {
        var content = subscriptionPausedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func subscriptionPausedContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Subscription Renewal",
            "outcome": "Paused - " + tier,
            "result": "fail"
        ]
    }
    public func subscriptionPaused(tier: String) throws {
        let content = subscriptionPausedContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func subscriptionUpsold(tier: String, method: String, price: String, term: String) throws {
        var content = subscriptionUpsoldContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func subscriptionUpsold(tier: String, method: String, price: String) throws {
        var content = subscriptionUpsoldContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func subscriptionUpsold(tier: String, method: String) throws {
        var content = subscriptionUpsoldContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func subscriptionUpsoldContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Subscription Upsold",
            "outcome": "Upsold - " + tier,
            "result": "success"
        ]
    }
    public func subscriptionUpsold(tier: String) throws {
        let content = subscriptionUpsoldContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func subscriptionUpsellDeclined(tier: String, method: String, price: String, term: String) throws {
        var content = subscriptionUpsellDeclinedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func subscriptionUpsellDeclined(tier: String, method: String, price: String) throws {
        var content = subscriptionUpsellDeclinedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func subscriptionUpsellDeclined(tier: String, method: String) throws {
        var content = subscriptionUpsellDeclinedContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func subscriptionUpsellDeclinedContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Subscription Upsold",
            "outcome": "Declined - " + tier,
            "result": "fail"
        ]
    }
    public func subscriptionUpsellDeclined(tier: String) throws {
        let content = subscriptionUpsellDeclinedContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func subscriptionDownsell(tier: String, method: String, price: String, term: String) throws {
        var content = subscriptionDownsellContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        content = addTermToContent(content: content, term: term)
        try outcomeAdd(content: content)
    }
    public func subscriptionDownsell(tier: String, method: String, price: String) throws {
        var content = subscriptionDownsellContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func subscriptionDownsell(tier: String, method: String) throws {
        var content = subscriptionDownsellContent(tier: tier)
        content = addMethodToContent(content: content, method: method)
        try outcomeAdd(content: content)
    }
    private func subscriptionDownsellContent(tier: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Subscription Upsold",
            "outcome": "Downsell - " + tier,
            "result": "fail"
        ]
    }
    public func subscriptionDownsell(tier: String) throws {
        let content = subscriptionDownsellContent(tier: tier)
        try outcomeAdd(content: content)
    }

    public func adClicked(provider: String, id: String, price: String) throws {
        var content = adClickedContent(provider: provider)
        content = addIdToContent(content: content, id: id)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func adClicked(provider: String, id: String) throws {
        var content = adClickedContent(provider: provider)
        content = addIdToContent(content: content, id: id)
        try outcomeAdd(content: content)
    }
    private func adClickedContent(provider: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Advertisement",
            "outcome": "Ad Click - " + provider,
            "result": "success"
        ]
    }
    public func adClicked(provider: String) throws {
        let content = adClickedContent(provider: provider)
        try outcomeAdd(content: content)
    }

    public func adIgnored(provider: String, id: String, price: String) throws {
        var content = adIgnoredContent(provider: provider)
        content = addIdToContent(content: content, id: id)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func adIgnored(provider: String, id: String) throws {
        var content = adIgnoredContent(provider: provider)
        content = addIdToContent(content: content, id: id)
        try outcomeAdd(content: content)
    }
    private func adIgnoredContent(provider: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Advertisement",
            "outcome": "Ad Ignored - " + provider,
            "result": "fail"
        ]
    }
    public func adIgnored(provider: String) throws {
        let content = adIgnoredContent(provider: provider)
        try outcomeAdd(content: content)
    }

    public func referral(kind: String, detail: String) throws {
        let content = [
            "superOutcome": "Referral",
            "outcome": "Referred - " + kind,
            "result": "success",
            "details": detail
        ]
        try outcomeAdd(content: content)
    }
    public func referral(kind: String) throws {
        let content = [
            "superOutcome": "Referral",
            "outcome": "Referred - " + kind,
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func referralDeclined(kind: String, detail: String) throws {
        let content = [
            "superOutcome": "Referral",
            "outcome": "Declined - " + kind,
            "result": "fail",
            "details": detail
        ]
        try outcomeAdd(content: content)
    }
    public func referralDeclined(kind: String) throws {
        let content = [
            "superOutcome": "Referral",
            "outcome": "Declined - " + kind,
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    // Ecommerce Related Outcomes tests

    public func productAddedToCart(product: String) throws {
        let content = [
            "superOutcome": "Add Product To Cart",
            "outcome": "Add - " + product,
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func productNotAddedToCart(product: String) throws {
        let content = [
            "superOutcome": "Add Product To Cart",
            "outcome": "Ignore - " + product,
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    public func upsold(product: String, price: String) throws {
        var content = upsoldContent(product: product)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    private func upsoldContent(product: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Upsold Product",
            "outcome": "Upsold - " + product,
            "result": "success"
        ]
    }
    public func upsold(product: String) throws {
        let content = upsoldContent(product: product)
        try outcomeAdd(content: content)
    }

    public func upsellDismissed(product: String, price: String) throws {
        var content = upsellDismissedContent(product: product)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    private func upsellDismissedContent(product: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Upsold Product",
            "outcome": "Dismissed - " + product,
            "result": "fail"
        ]
    }
    public func upsellDismissed(product: String) throws {
        let content = upsellDismissedContent(product: product)
        try outcomeAdd(content: content)
    }

    public func checkedOut() throws {
        let content = [
            "superOutcome": "Customer Checkout",
            "outcome": "Checked Out",
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func checkoutCanceled() throws {
        let content = [
            "superOutcome": "Customer Checkout",
            "outcome": "Canceled",
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    public func productRemoved(product: String) throws {
        let content = [
            "superOutcome": "Customer Checkout",
            "outcome": "Product Removed - " + product,
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    public func purchased(method: String, price: String) throws {
        var content = purchasedContent(method: method)
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    private func purchasedContent(method: String) -> Dictionary<String, Any> {
        [
            "superOutcome": "Customer Purchase",
            "outcome": "Purchase - " + method,
            "result": "success"
        ]
    }
    public func purchased(method: String) throws {
        let content = purchasedContent(method: method)
        try outcomeAdd(content: content)
    }

    public func purchaseCanceled(method: String, price: String) throws {
        var content = purchaseCanceledContent()
        content["outcome"] = "Canceled - " + method
        content = addPriceToContent(content: content, price: price)
        try outcomeAdd(content: content)
    }
    public func purchaseCanceled(method: String) throws {
        var content = purchaseCanceledContent()
        content["outcome"] = "Canceled - " + method
        try outcomeAdd(content: content)
    }
    private func purchaseCanceledContent() -> Dictionary<String, Any> {
        [
            "superOutcome": "Customer Purchase",
            "outcome": "Canceled",
            "result": "fail"
        ]
    }
    public func purchaseCanceled() throws {
        let content = purchaseCanceledContent()
        try outcomeAdd(content: content)
    }

    public func promiseFulfilled() throws {
        let content = [
            "superOutcome": "Promise Fulfillment",
            "outcome": "Fulfilled",
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func promiseUnfulfilled() throws {
        let content = [
            "superOutcome": "Promise Fulfillment",
            "outcome": "Unfulfilled",
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    public func productKept(product: String) throws {
        let content = [
            "superOutcome": "Product Disposition",
            "outcome": "Kept - " + product,
            "result": "success"
        ]
        try outcomeAdd(content: content)
    }

    public func productReturned(product: String) throws {
        let content = [
            "superOutcome": "Product Disposition",
            "outcome": "Returned - " + product,
            "result": "fail"
        ]
        try outcomeAdd(content: content)
    }

    // Stock Milestones:

    public func featureAttempted(feature: String, detail: String) throws {
        let content = [
            "category": "Feature",
            "action": "Attempted",
            "name": feature,
            "details": detail
        ]
        try journeyAdd(content: content)
    }
    public func featureAttempted(feature: String) throws {
        let content = [
            "category": "Feature",
            "action": "Attempted",
            "name": feature
        ]
        try journeyAdd(content: content)
    }

    public func featureCompleted(feature: String, detail: String) throws {
        let content = [
            "category": "Feature",
            "action": "Completed",
            "name": feature,
            "details": detail
        ]
        try journeyAdd(content: content)
    }
    public func featureCompleted(feature: String) throws {
        let content = [
            "category": "Feature",
            "action": "Completed",
            "name": feature
        ]
        try journeyAdd(content: content)
    }

    public func featureFailed(feature: String, detail: String) throws {
        let content = [
            "category": "Feature",
            "action": "Failed",
            "name": feature,
            "details": detail
        ]
        try journeyAdd(content: content)
    }
    public func featureFailed(feature: String) throws {
        let content = [
            "category": "Feature",
            "action": "Failed",
            "name": feature
        ]
        try journeyAdd(content: content)
    }

    public func contentViewed(type: String, identifier: String) throws {
        let content = [
            "category": "Content",
            "action": "Viewed",
            "type": type,
            "identifier": identifier
        ]
        try journeyAdd(content: content)
    }
    public func contentViewed(type: String) throws {
        let content = [
            "category": "Content",
            "action": "Viewed",
            "type": type
        ]
        try journeyAdd(content: content)
    }

    public func contentEdited(type: String, identifier: String, detail: Any) throws {
        let content = [
            "category": "Content",
            "action": "Edited",
            "type": type,
            "identifier": identifier,
            "details": detail
        ]
        try journeyAdd(content: content)
    }
    public func contentEdited(type: String, identifier: String) throws {
        let content = [
            "category": "Content",
            "action": "Edited",
            "type": type,
            "identifier": identifier
        ]
        try journeyAdd(content: content)
    }
    public func contentEdited(type: String) throws {
        let content = [
            "category": "Content",
            "action": "Edited",
            "type": type
        ]
        try journeyAdd(content: content)
    }

    public func contentCreated(type: String, identifier: String) throws {
        let content = [
            "category": "Content",
            "action": "Created",
            "type": type,
            "identifier": identifier
        ]
        try journeyAdd(content: content)
    }
    public func contentCreated(type: String) throws {
        let content = [
            "category": "Content",
            "action": "Created",
            "type": type
        ]
        try journeyAdd(content: content)
    }

    public func contentDeleted(type: String, identifier: String) throws {
        let content = [
            "category": "Content",
            "action": "Deleted",
            "type": type,
            "identifier": identifier
        ]
        try journeyAdd(content: content)
    }
    public func contentDeleted(type: String) throws {
        let content = [
            "category": "Content",
            "action": "Deleted",
            "type": type
        ]
        try journeyAdd(content: content)
    }

    public func contentArchived(type: String, identifier: String) throws {
        let content = [
            "category": "Content",
            "action": "Archived",
            "type": type,
            "identifier": identifier
        ]
        try journeyAdd(content: content)
    }
    public func contentArchived(type: String) throws {
        let content = [
            "category": "Content",
            "action": "Archived",
            "type": type
        ]
        try journeyAdd(content: content)
    }

    public func contentRequested(type: String, identifier: String) throws {
        let content = [
            "category": "Content",
            "action": "Requested",
            "type": type,
            "identifier": identifier
        ]
        try journeyAdd(content: content)
    }
    public func contentRequested(type: String) throws {
        let content = [
            "category": "Content",
            "action": "Requested",
            "type": type
        ]
        try journeyAdd(content: content)
    }

    public func contentSearched(type: String) throws {
        let content = [
            "category": "Content",
            "action": "Searched",
            "type": type
        ]
        try journeyAdd(content: content)
    }

    // Custom Milestones

    public func milestone(category: String, operation: String, name: String, detail: Any) throws {
        let content = [
            "category": category,
            "action": operation,
            "name": name,
            "details": detail
        ]
        try journeyAdd(content: content)
    }

    // API Communication:

    public func commit() throws -> Task<JSON, Error> {
        let params: Dictionary<String, Any> = [
            "id": id(),
            "journey": journey(),
            "token": Xenon.apiKey,
            "timestamp": timestamp(),
            "ignore-certificate-errors": Xenon.allowSelfSigned
        ]
        if (Xenon.apiKey == "") {
            throw Errors.authenticationTokenError("API Key not set.")
        }

        reset()

        return Task {
            var result = JSON([:])
            do {
                result = try await journeyApi.with(apiUrl: Xenon.apiUrl).fetch(data: params).value
            } catch {
                try restore()
                throw error
            }
            return result
        }
    }

    public func heartbeat() throws -> Task<JSON, Error> {
        let params: Dictionary<String, Any> = [
            "id": id(),
            "journey": journey(),
            "token": Xenon.apiKey,
            "timestamp": timestamp(),
            "tags": Xenon.variants_,
            "platform": Xenon.platform_,
            "ignore-certificate-errors": Xenon.allowSelfSigned
        ]
        if (Xenon.apiKey == "") {
            throw Errors.authenticationTokenError("API Key not set.")
        }

        reset()

        return Task {
            var result = JSON([:])
            do {
                result = try await heartbeatApi.with(apiUrl: Xenon.apiUrl).fetch(data: params).value
            } catch {
                try restore()
                throw error
            }
            return result
        }
    }

    public func deanonymize(person: Dictionary<String, Any>) throws -> Task<JSON, Error> {
        let params: Dictionary<String, Any> = [
            "id": id(),
            "person": person,
            "token": Xenon.apiKey,
            "timestamp": timestamp(),
            "ignore-certificate-errors": Xenon.allowSelfSigned
        ]
        if (Xenon.apiKey == "") {
            throw Errors.authenticationTokenError("API Key not set.")
        }

        return try deanonApi.with(apiUrl: Xenon.apiUrl).fetch(data: params)
    }

    // Internals:

    public func id() -> String {
        Xenon._id
    }

    public func id(_id: String) {
        Xenon._id = _id
    }

    public func newId() {
        Xenon._id = UUID().uuidString
    }

    internal func outcomeAdd(content: Dictionary<String, Any>) throws {
        var contentToSave = content;
        if (!Xenon.platform_.isEmpty) {
            contentToSave["platform"] = Xenon.platform_
        };
        if (!Xenon.variants_.isEmpty) {
            contentToSave["tags"] = Xenon.variants_
        };

        try journeyAdd(content: contentToSave)
    }

    internal func journeyAdd(content: Dictionary<String, Any>) throws {
        var contentToSave = content;
        var journey = journey();
        contentToSave["timestamp"] = timestamp()
        if (journey.count > 0) {
            var last = journey.last as! Dictionary<String, Any>

            if (isDuplicate(last: last, content: contentToSave)) {
                let count: Int = last["count"] != nil ? last["count"] as! Int : 1
                last["count"] = count + 1
                journey.indices.last.map {
                    journey[$0] = last
                }
            } else {
                journey.append(contentToSave)
            }
        } else {
            journey = [contentToSave]
        }
        storeJourney(journey: journey)
    }

    private func isDuplicate(last: Dictionary<String, Any>, content: Dictionary<String, Any>) -> Bool {
        let lastKeys = [String](last.keys)
        let contentKeys = [String](content.keys)
        let lastKeysSet: Set = Set(lastKeys)
        let contentKeysSet: Set = Set(contentKeys)
        if (!lastKeysSet.isSuperset(of: contentKeysSet)) {
            return false
        }
        if (!contentKeys.contains("category") || !lastKeys.contains("category")) {
            return false
        }
        if (content["category"] as! String != last["category"] as! String) {
            return false
        }
        if (!contentKeys.contains("action") || !lastKeys.contains("action")) {
            return false
        }
        if (content["action"] as! String != last["action"] as! String) {
            return false
        }
        return (duplicateFeature(last: last, content: content, lastKeys: lastKeys, contentKeys: contentKeys) ||
                duplicateContent(last: last, content: content, lastKeys: lastKeys, contentKeys: contentKeys) ||
                duplicateMilestone(last: last, content: content, lastKeys: lastKeys, contentKeys: contentKeys))
    }


    private func duplicateFeature(last: Dictionary<String, Any>, content: Dictionary<String, Any>,
                                  lastKeys: Array<String>, contentKeys: Array<String>) -> Bool {
        if (content["category"] as! String != "Feature" || last["category"] as! String != "Feature") {
            return false
        }
        return content["name"] as! String == last["name"] as! String;
    }

    private func duplicateContent(last: Dictionary<String, Any>, content: Dictionary<String, Any>,
                                  lastKeys: Array<String>, contentKeys: Array<String>) -> Bool {
        if (content["category"] as! String != "Content" || last["category"] as! String != "Content") {
            return false
        }
        if (!contentKeys.contains("type") && !lastKeys.contains("type")) {
            return true
        }
        if (content["type"] as! String != last["type"] as! String) {
            return false
        }
        if (!contentKeys.contains("identifier") && !lastKeys.contains("identifier")) {
            return true
        }
        if (content["identifier"] as! String != last["identifier"] as! String) {
            return false
        }
        if (!contentKeys.contains("details") && !lastKeys.contains("details")) {
            return true
        }
        return content["details"] as! String == last["details"] as! String;
    }

    private func duplicateMilestone(last: Dictionary<String, Any>, content: Dictionary<String, Any>,
                                    lastKeys: Array<String>, contentKeys: Array<String>) -> Bool {
        if (content["category"] as! String == "Feature" || last["category"] as! String == "Feature") {
            return false
        }
        if (content["category"] as! String == "Content" || last["category"] as! String == "Content") {
            return false
        }
        if (content["name"] as! String != last["name"] as! String) {
            return false
        }
        return content["details"] as! String == last["details"] as! String;
    }

    public func journey() -> Array<Any> {
        Xenon._journey
    }

    private func storeJourney(journey: Array<Any>) {
        Xenon._journey = journey
    }

    public func reset() {
        restoreJourney = journey()
        Xenon._journey = []
    }

    public func restore() throws {
        let currentJourney = journey()
        if (currentJourney.count > 0) {
            var result: Array<Any> = []
            for item in restoreJourney {
                result.append(item)
            }
            for item in currentJourney {
                result.append(item)
            }
            restoreJourney = result;
        }
        storeJourney(journey: restoreJourney)
        restoreJourney = []
    }

    public func selfSignedAllowed() -> Bool {
        Xenon.allowSelfSigned
    }

    private func timestamp() -> Double {
        NSDate().timeIntervalSince1970
    }
}
