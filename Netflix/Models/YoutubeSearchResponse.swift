//
//  YoutubeSearchResult.swift
//  Netflix
//
//  Created by yudonlee on 2022/08/22.
//

import Foundation


struct YoutubeSearchResponse: Codable {
//    json 파싱 테스트를 위한 용도
//    let etag: String
    let items: [VideoElement]
}


struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}


/*
 items =     (
             {
         etag = lKCmmHSFHZkkIHR7sb1Uq4ypTgE;
         id =             {
             kind = "youtube#video";
             videoId = 1ddU8gf2i9k;
         };
         kind = "youtube#searchResult";
     },
 
 */
