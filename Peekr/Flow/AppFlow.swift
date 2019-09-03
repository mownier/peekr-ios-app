//
//  AppFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 8/28/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class AppFlow: BaseFlowDefault {
    
    private let auth: AuthFlow
    private let onboarding: OnboardingFlow
    
    override init(window: UIWindow) {
        auth = AuthFlow(window: window)
        onboarding = OnboardingFlow(window: window)
        
        super.init(window: window)

        makeLandingScreenAsRootOf(window: window)
    }
    
    @discardableResult
    override func registerObservers() -> Bool {
        return [
            auth.registerObservers(),
            onboarding.registerObservers()
        ].reduce(true, { result, item -> Bool in
            return result && item
        })
    }
    
    @discardableResult
    override func unregisterObservers() -> Bool {
        return [
            auth.unregisterObservers(),
            onboarding.unregisterObservers()
        ].reduce(true, { result, item -> Bool in
            return result && item
        })
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            auth.allObservers(),
            onboarding.allObservers()
        ].joined().map({ $0 })
    }
}

func appFlowWith(window: UIWindow?) -> AppFlow? {
    guard window != nil else {
        return nil
    }
    return AppFlow(window: window!)
}
