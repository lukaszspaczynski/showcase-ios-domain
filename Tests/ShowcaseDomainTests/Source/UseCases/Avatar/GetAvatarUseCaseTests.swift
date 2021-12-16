//
//  GetAvatarUseCaseTests.swift
//  ShowcaseDomainTests
//
//  Created by Lukasz Spaczynski on 13/12/2021.
//

#if canImport(UIKit)

import Nimble
import RxBlocking
import RxSwift
import ShowcaseData
import ShowcaseDataMocks
import XCTest

@testable import ShowcaseDomain

final class GetAvatarUseCaseTests: XCTestCase {
    private enum DummyError: Error {
        case dummy
    }

    func testExecuteReturnsValidResult() throws {
        // GIVEN
        let (sut, imageService, imageFilterService, url) =
            Self.prepareTestComponents()

        // WHEN
        imageService.getRemoteImageInvokedResult = .valid
        imageFilterService.applyFiltersInvokedResult = .valid

        let action = sut.execute(url)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned action] in
            action.execute()
        }

        let result = try action
            .elements
            .toBlocking(timeout: 1)
            .first()

        // THEN
        expect(imageService.getRemoteImageInvoked).to(beTrue())
        expect(imageFilterService.applyFiltersInvoked).to(beTrue())
        expect(result).toNot(beNil())
        expect(result!.pixelized.count).to(equal(7))
    }

    func testExecuteReturnsFailedResultOnImageServiceFailure() throws {
        // GIVEN
        let (sut, imageService, imageFilterService, url) =
            Self.prepareTestComponents()

        // WHEN
        imageService.getRemoteImageInvokedResult = .invalid(error: DummyError.dummy)
        imageFilterService.applyFiltersInvokedResult = .valid

        let action = sut.execute(url)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned action] in
            action.execute()
        }

        let result = try action
            .errors
            .toBlocking(timeout: 1)
            .first()

        // THEN
        expect(imageService.getRemoteImageInvoked).to(beTrue())
        expect(imageFilterService.applyFiltersInvoked).to(beFalse())
        expect(result).toNot(beNil())
    }

    func testExecuteReturnsFailedResultOnImageFilterServiceFailure() throws {
        // GIVEN
        let (sut, imageService, imageFilterService, url) =
            Self.prepareTestComponents()

        // WHEN
        imageService.getRemoteImageInvokedResult = .valid
        imageFilterService.applyFiltersInvokedResult = .invalid(error: DummyError.dummy)

        let action = sut.execute(url)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned action] in
            action.execute()
        }

        let result = try action
            .errors
            .toBlocking(timeout: 1)
            .first()

        // THEN
        expect(imageService.getRemoteImageInvoked).to(beTrue())
        expect(imageFilterService.applyFiltersInvoked).to(beTrue())
        expect(result).toNot(beNil())
    }
}

extension GetAvatarUseCaseTests {
    typealias TestComponents = (
        sut: GetAvatarUseCase,
        imageService: MockedImageService,
        imageFilterService: MockedImageFilterService,
        url: URL
    )

    static func prepareTestComponents() -> TestComponents {
        let imageService = MockedImageService()
        let imageFilterService = MockedImageFilterService()
        let url = URL(string: "http://dummy.net")!
        let sut = ConcreteGetAvatarUseCase(
            imageService: imageService,
            imageFilterService: imageFilterService
        )

        return (sut, imageService, imageFilterService, url)
    }
}

#endif
