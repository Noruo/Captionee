//
//  Caption.swift
//  enPiT2SUProduct
//
//  Created by 池崎雄介 on 2017/11/30.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import SpeechToTextV1

/* 字幕の情報を管理するクラス */
class Caption: NSObject, NSCoding {
    
    var sentences: [Sentence]
    
    init(_ results: SpeechRecognitionResults) {
        sentences = [Sentence]()
        
        print("Results count = \(results.results.count)")
        
        for result in results.results {
            let sentence = result.alternatives[0].transcript
            let startTime = result.alternatives[0].timestamps![0].startTime
            let endTime = result.alternatives[0].timestamps![result.alternatives[0].timestamps!.count-1].endTime
            
            sentences.append(Sentence(sentence, startTime, endTime))
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sentences, forKey: "Sentences")
    }
    
    required init?(coder aDecoder: NSCoder) {
        sentences = aDecoder.decodeObject(forKey: "Sentences") as! [Sentence]
    }
    
    /* 字幕の一文を管理するクラス */
    @objc(_TtCC15enPiT2SUProduct7Caption8Sentence)class Sentence: NSObject, NSCoding {
        
        var sentence: String!
        var startTime: Double!
        var endTime: Double!
        
        init(_ sentence: String, _ startTime: Double, _ endTime: Double) {
            self.sentence = sentence
            self.startTime = startTime
            self.endTime = endTime
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(sentence, forKey: "Sentence")
            aCoder.encode(startTime, forKey: "StartTime")
            aCoder.encode(endTime, forKey: "EndTime")
        }
        
        required init?(coder aDecoder: NSCoder) {
            sentence = aDecoder.decodeObject(forKey: "Sentence") as! String
            startTime = aDecoder.decodeObject(forKey: "StartTime") as! Double
            endTime = aDecoder.decodeObject(forKey: "EndTime") as! Double
        }
        
    }
    
}
