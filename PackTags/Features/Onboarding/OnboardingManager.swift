//
//  Core.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

class OnboardingManager {
    static let shared = OnboardingManager()

    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: SettingsKey.hasSeenOnboarding)
    }

    func setIsNotNewUser() {
        UserDefaults.standard.setValue(true, forKey: SettingsKey.hasSeenOnboarding)
    }
}
