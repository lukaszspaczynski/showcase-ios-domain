//
//  GetAvatarUseCaseOutputMockFactory.swift
//  ShowcaseDomainMocks
//
//  Created by Lukasz Spaczynski on 06/12/2021.
//

#if canImport(UIKit)

import Foundation
import Kanna
import ShowcaseData
import ShowcaseDomain
import UIKit

public enum GetAvatarUseCaseOutputMockFactory {
    public static func mock() -> GetAvatarUseCaseOutput {
        GetAvatarUseCaseOutput(
            avatar: UIImage(systemName: "heart.fill")!,
            pixelized: [UIImage(systemName: "heart.fill")!, UIImage(systemName: "heart.fill")!]
        )
    }
}

#endif
