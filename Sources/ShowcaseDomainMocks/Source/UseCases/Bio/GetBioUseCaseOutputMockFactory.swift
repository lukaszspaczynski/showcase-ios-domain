//
//  GetBioUseCaseOutputMockFactory.swift
//  ShowcaseDomainMocks
//
//  Created by Lukasz Spaczynski on 26/11/2021.
//

#if canImport(UIKit)

import Foundation
import Kanna
import ShowcaseData
import ShowcaseDomain

public enum GetBioUseCaseOutputMockFactory {
    typealias Link = GetBioUseCaseOutput.SocialLink
    typealias Attr = NSAttributedString

    public static func mock() -> GetBioUseCaseOutput {
        let dummyUrl = URL(string: "http://dummy.net")!

        return GetBioUseCaseOutput(
            bio: Attr(string: "mocked bio"),
            links: [
                Link(title: Attr(string: "mocked link 1"),
                     url: dummyUrl),
                Link(title: Attr(string: "mocked link 2"),
                     url: dummyUrl),
                Link(title: Attr(string: "mocked link 3"),
                     url: dummyUrl),
            ]
        )
    }
}

#endif
