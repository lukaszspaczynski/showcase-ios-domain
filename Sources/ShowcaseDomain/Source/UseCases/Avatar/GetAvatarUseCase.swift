//
//  GetAvatarUseCase.swift
//  ShowcaseDomain
//
//  Created by Lukasz Spaczynski on 01/12/2021.
//

#if canImport(UIKit)

import Action
import RxSwift
import ShowcaseData
import ShowcaseExtensions
import UIKit

public protocol GetAvatarUseCase {
    typealias Input = URL
    typealias Output = Action<Void, GetAvatarUseCaseOutput>

    func execute(_ input: Input) -> Output
}

public struct GetAvatarUseCaseOutput {
    public let avatar: UIImage
    public let pixelized: [UIImage]

    public init(avatar: UIImage, pixelized: [UIImage]) {
        self.avatar = avatar
        self.pixelized = pixelized
    }
}

public final class ConcreteGetAvatarUseCase: GetAvatarUseCase, UseCase {
    let imageService: ImageService
    let imageFilterService: ImageFilterService

    public init(
        imageService: ImageService,
        imageFilterService: ImageFilterService
    ) {
        self.imageService = imageService
        self.imageFilterService = imageFilterService
    }

    public func execute(_ input: Input) -> Output {
        let actionObservable = imageService
            .getRemoteImage(input)
            .flatMap { $0.asObservable() }
            .flatMap(map)
            .map { GetAvatarUseCaseOutput(
                avatar: $0.filtered.last ?? $0.original,
                pixelized: $0.filtered
            ) }

        return Action { _ in
            actionObservable
        }
    }

    private func map(_ image: UIImage) -> Observable<(original: UIImage, filtered: [UIImage])> {
        let images = stride(from: 1, through: 20, by: 3)
            .map { [unowned self] in self.pixellate(image, scale: $0) }

        return Observable
            .combineLatest(images)
            .map { $0.sorted { $0.scale >= $1.scale } }
            .map { $0.map(\.image) }
            .map { (image, $0) }
    }

    private func pixellate(_ image: UIImage, scale: Int) -> Observable<(scale: Int, image: UIImage)> {
        imageFilterService
            .applyFilters(image, [
                .circle,
                .pixellate(scale: scale),
            ])
            .flatMap { $0.asObservable() }
            .map { (scale, $0) }
    }
}

#endif
