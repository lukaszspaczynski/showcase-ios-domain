//
//  GetBioUseCaseTests.swift
//  ShowcaseDomainTests
//
//  Created by Lukasz Spaczynski on 19/11/2021.
//

#if canImport(UIKit)

import Nimble
import RxBlocking
import RxSwift
import ShowcaseData
import ShowcaseDataMocks
import XCTest

@testable import ShowcaseDomain

final class GetBioUseCaseTests: XCTestCase {
    private enum DummyError: Error {
        case dummy
    }

    func testExecuteReturnsValidResult() throws {
        // GIVEN
        let (sut, bioRepository, templatesRepository) =
            Self.prepareTestComponents()

        // WHEN
        bioRepository.getBioInvokedResult = .valid
        templatesRepository.getTemplateInvokedResult = .map { name in
            switch name {
            case RichTextTemplateName.bio:
                return MockedRichTextTemplateNames.bio
            case RichTextTemplateName.bioLink:
                return MockedRichTextTemplateNames.bioLink
            default:
                return MockedRichTextTemplateNames.notExisting
            }
        }

        let action = sut.execute(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned action] in
            action.execute()
        }

        let result = try action
            .elements
            .toBlocking(timeout: 1)
            .first()

        // THEN
        expect(bioRepository.getBioInvoked).to(beTrue())
        expect(templatesRepository.getTemplateInvoked).to(beTrue())
        expect(result).toNot(beNil())
    }

    func testExecuteReturnsFailedResultOnBioRepositoryFailure() throws {
        // GIVEN
        let (sut, bioRepository, templatesRepository) =
            Self.prepareTestComponents()

        // WHEN
        bioRepository.getBioInvokedResult = .invalid(error: DummyError.dummy)
        templatesRepository.getTemplateInvokedResult = .map { name in
            switch name {
            case RichTextTemplateName.bio:
                return MockedRichTextTemplateNames.bio
            case RichTextTemplateName.bioLink:
                return MockedRichTextTemplateNames.bioLink
            default:
                return MockedRichTextTemplateNames.notExisting
            }
        }

        let action = sut.execute(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned action] in
            action.execute()
        }

        let result = try action
            .errors
            .toBlocking(timeout: 1)
            .first()

        // THEN
        expect(bioRepository.getBioInvoked).to(beTrue())
        expect(templatesRepository.getTemplateInvoked).to(beTrue())
        expect(result).toNot(beNil())
    }

    func testExecuteReturnsFailedResultOnTemplatesRepositoryFailure() throws {
        // GIVEN
        let (sut, bioRepository, templatesRepository) =
            Self.prepareTestComponents()

        // WHEN
        bioRepository.getBioInvokedResult = .valid
        templatesRepository.getTemplateInvokedResult = .invalid(error: DummyError.dummy)

        let action = sut.execute(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned action] in
            action.execute()
        }

        let result = try action
            .errors
            .toBlocking(timeout: 1)
            .first()

        // THEN
        expect(bioRepository.getBioInvoked).to(beTrue())
        expect(templatesRepository.getTemplateInvoked).to(beTrue())
        expect(result).toNot(beNil())
    }
}

extension GetBioUseCaseTests {
    typealias TestComponents = (
        sut: GetBioUseCase,
        bioRepository: MockedBioRepository,
        templatesRepository: MockedRichTextTemplatesRepository
    )

    static func prepareTestComponents() -> TestComponents {
        let bioRepository = MockedBioRepository()
        let templatesRepository = MockedRichTextTemplatesRepository()
        let sut = ConcreteGetBioUseCase(
            bioRepository: bioRepository,
            templatesRepository: templatesRepository
        )

        return (sut, bioRepository, templatesRepository)
    }
}

#endif
