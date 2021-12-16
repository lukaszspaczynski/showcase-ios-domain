//
//  MockedGetBioUseCase.swift
//  ShowcaseDomainMocks
//
//  Created by Lukasz Spaczynski on 26/11/2021.
//

#if canImport(UIKit)

import Action
import Foundation
import RxSwift
import ShowcaseDomain

public final class MockedGetBioUseCase: GetBioUseCase {
    public init() {}

    public enum ExecuteResult {
        case valid
        case empty
        case failure(Error)
        case output(GetBioUseCaseOutput)
        case callback
    }

    public var executeInvoked: Bool = false
    public var executeInvokedResult: ExecuteResult = .empty
    public var executeInvokedResultCallback: ((AnyObserver<GetBioUseCaseOutput>) -> Void)?
    public func execute(_ input: Input) -> Output {
        executeInvoked = true

        return resolveExecuteResult(executeInvokedResult, input)
    }
}

extension MockedGetBioUseCase {
    private func resolveExecuteResult(
        _ type: ExecuteResult,
        _: Input
    ) -> Output {
        switch type {
        case .empty:
            return Output { .empty() }
        case let .failure(error):
            return Output { .error(error) }
        case let .output(output):
            return Output { .just(output) }
        case .valid:
            let output = GetBioUseCaseOutputMockFactory.mock()

            return Output { .just(output) }
        case .callback:
            return Output {
                return Observable<GetBioUseCaseOutput>.create { [unowned self] observer in

                    self.executeInvokedResultCallback?(observer)

                    return Disposables.create()
                }
            }
        }
    }
}

#endif
