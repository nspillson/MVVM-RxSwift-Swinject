//
//  APIManager.swift
//  MVVM-RxSwift
//
//  Created by Nikola Tomovic on 3/24/17.
//  Copyright © 2017 Nikola Tomovic. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import RxSwift

public final class APIManager
{
    public init() { }
    
    private let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 40
        configuration.timeoutIntervalForResource = 40
        
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    func getScores(fromTime: TimeInterval, untilTime: TimeInterval) -> Observable<[Match]> {
        let observable = Observable<[Match]>.create { [weak self] observer in
            self?.manager.request(LivescoresRouter.scores(fromTime: fromTime, untilTime: untilTime)).validate().responseArray(keyPath: "livescores") { (response: DataResponse<[Match]>) in
                
                switch response.result {
                case .success(let matchs):
                    observer.onNext(matchs)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        return observable.shareReplay(1)
    }
    
    func getLivescores() -> Single<[Match]> {
        return Single<[Match]>.create { [weak self] observer in
            self?.manager.request(LivescoresRouter.liveScores).validate().responseArray(keyPath: "livescores") { (response: DataResponse<[Match]>) in
                
                switch response.result {
                case .success(let matchs):
                    observer(.success(matchs))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func getMatchCast(matchId: String) -> Observable<MatchCast> {
        let observable = Observable<MatchCast>.create { [weak self] observer in
            let urlString = Constants.API.Endpoints.baseUrl + Constants.API.Endpoints.matchcast + matchId
            self?.manager.request(urlString).validate().responseObject( keyPath: "matchcast") { (response: DataResponse<MatchCast>) in
                
                switch response.result {
                case .success(let matchcast):
                    observer.onNext(matchcast)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        return observable.shareReplay(1)
    }
    
}
