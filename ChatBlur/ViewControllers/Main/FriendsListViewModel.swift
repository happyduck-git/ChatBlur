//
//  FriendsListViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import Foundation
import Supabase
import RxSwift
import RxCocoa
import RxDataSources

final class FriendsListViewModel: ViewModelType {
    
    private let supabaseManager: SupabaseManager = SupabaseManager.shared
    
    private let currentUser: PublishRelay<ChatUser>
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    init(currentUser: PublishRelay<ChatUser>) {
        self.currentUser = currentUser
    }
    
    //MARK: - View Model Data
    struct Input {
       
    }
    
    struct Output {
//        let sectionData: PublishRelay<[SectionData]>
    }
    
    func transform(input: Input) -> Output {
        
        let sections: [Section] = Section.allCases
        var sectionData: [SectionData] = []
        
        // first section
        self.currentUser.subscribe(onNext: {
            print("User information: \($0.username)")
        })
        .disposed(by: disposeBag)
        
        // second section

        
        for section in sections {
            sectionData.append(SectionData(header: section.rawValue,
                                           items: []))
        }
       
        return Output()
//        return Output(sectionData: <#PublishRelay<[FriendsListViewModel.SectionData]>#>)
    }
}

extension FriendsListViewModel {
    
    private func addFriendsToList(_ email: String) async throws {
        try await supabaseManager.saveFriend(with: email)
    }
    
    private func fetchFriendsList() async throws {
        
    }
}

extension FriendsListViewModel {
    enum Section: String, CaseIterable {
        case me
        case friends
    }
}

struct SectionData {
    let header: String
    var items: [Item]
}

extension SectionData: SectionModelType {
    typealias Item = ChatUser
    
    init(original: SectionData, items: [ChatUser]) {
        self = original
        self.items = items
    }
}
