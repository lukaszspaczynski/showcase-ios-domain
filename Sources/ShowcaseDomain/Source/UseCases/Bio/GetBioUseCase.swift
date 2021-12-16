//
//  GetBioUseCase.swift
//  ShowcaseDomain
//
//  Created by Lukasz Spaczynski on 22/11/2021.
//

#if canImport(UIKit)

import Action
import RxSwift
import ShowcaseData
import Foundation

public protocol GetBioUseCase {
    typealias Input = Void?
    typealias Output = Action<Void, GetBioUseCaseOutput>

    func execute(_ input: Input) -> Output
}

public struct GetBioUseCaseOutput {
    public struct SocialLink {
        public let title: NSAttributedString
        public let url: URL

        public init(title: NSAttributedString, url: URL) {
            self.title = title
            self.url = url
        }
    }

    public let bio: NSAttributedString
    public let links: [SocialLink]

    public init(bio: NSAttributedString, links: [GetBioUseCaseOutput.SocialLink]) {
        self.bio = bio
        self.links = links
    }
}

public final class ConcreteGetBioUseCase: GetBioUseCase, UseCase {
    private let bioRepository: BioRepository
    private let templatesRepository: RichTextTemplatesRepository

    public enum UseCaseError: Error {
        case underlyingError(Error?)
    }

    private enum BioTemplateKeys {
        case name
        case work
        case at
        case biograph

        var stringValue: String {
            switch self {
            case .name:
                return "%name%"
            case .work:
                return "%work%"
            case .at:
                return "%at%"
            case .biograph:
                return "%biograph%"
            }
        }
    }

    private enum BioLinkTemplateKeys {
        case link

        var stringValue: String {
            switch self {
            case .link:
                return "%link%"
            }
        }
    }

    public init(
        bioRepository: BioRepository,
        templatesRepository: RichTextTemplatesRepository
    ) {
        self.bioRepository = bioRepository
        self.templatesRepository = templatesRepository
    }

    public func execute(_: Input) -> Output {
        let bioObservable = bioRepository
            .getBio()
        let bioTemplateObservable = templatesRepository
            .getTemplate(RichTextTemplateName.bio)
        let linkTemplateObservable = templatesRepository
            .getTemplate(RichTextTemplateName.bioLink)

        let actionObservable = Observable
            .combineLatest(
                bioObservable,
                bioTemplateObservable,
                linkTemplateObservable
            )
            .flatMap(Self.map)

        let action: Action<Void, GetBioUseCaseOutput> = Action { _ in
            actionObservable
        }

        return action
    }

    private static func map(
        _ bio: Result<Bio, Error>,
        _ summaryTemplate: Result<RichTextTemplate, Error>,
        _ linkTemplate: Result<RichTextTemplate, Error>
    ) -> Observable<GetBioUseCaseOutput> {
        switch (bio, summaryTemplate, linkTemplate) {
        case let (.success(bio), .success(summaryTemplate), .success(linkTemplate)):

            let bioString = summaryTemplate.evaluate {
                ConcreteGetBioUseCase
                    .templateValues(bio)
            }

            let bioLinks = bio.links.map {
                link -> GetBioUseCaseOutput.SocialLink in

                let linkTitle = linkTemplate.evaluate {
                    ConcreteGetBioUseCase
                        .templateValues(link)
                }

                return GetBioUseCaseOutput.SocialLink(
                    title: linkTitle,
                    url: link.url
                )
            }

            let result = GetBioUseCaseOutput(
                bio: bioString,
                links: bioLinks
            )

            return .just(result)

        case let (.failure(error), _, _):
            return .error(UseCaseError.underlyingError(error))
        case let (_, .failure(error), _):
            return .error(UseCaseError.underlyingError(error))
        case let (_, _, .failure(error)):
            return .error(UseCaseError.underlyingError(error))
        }
    }

    private static func templateValues(_ bio: Bio) -> [String: String] {
        typealias Key = BioTemplateKeys

        let biograph = bio.bios.joined(separator: "\n\n")

        return [
            Key.at.stringValue: bio.location,
            Key.biograph.stringValue: biograph,
            Key.name.stringValue: bio.name,
            Key.work.stringValue: bio.role,
        ]
    }

    private static func templateValues(_ link: Bio.Link) -> [String: String] {
        typealias Key = BioLinkTemplateKeys

        return [
            Key.link.stringValue: link.title,
        ]
    }
}

#endif
