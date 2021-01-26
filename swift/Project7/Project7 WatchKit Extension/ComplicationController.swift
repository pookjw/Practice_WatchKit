//
//  ComplicationController.swift
//  Project7 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/26/21.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let positiveAnswers: Set<String> = ["It is certain", "It is decidedly so", "Without a doubt", "Yes definitely", "As I see it, yes", "Most likely", "Outlook good", "Yes", "Signs point to yes"]
    let uncertainAnswers: Set<String> = ["Reply hazy, try again", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again"]
    let negativeAnswers: Set<String> = ["Don't count on it", "My reply is no", "My sources say no", "Outlook not so good", "Very doubtful"]
    var allAnswers = [String]()
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        /*
         watchOS 7 이후로, Supported Complication Families는 Info.plist가 아니라, 아래 descripters에서 처리한다.
         https://developer.apple.com/documentation/clockkit/declaring_the_complications
         */
//        let descriptors = [
//            CLKComplicationDescriptor(identifier: "complication", displayName: "Project7", supportedFamilies: CLKComplicationFamily.allCases)
//            // Multiple complication support can be added here with more descriptors
//        ]
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Project7", supportedFamilies: [.modularSmall, .modularLarge])
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    // DEPRECATED
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let startDate = Date().addingTimeInterval(-86400)
        handler(startDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let endDate = Date().addingTimeInterval(86400)
        handler(endDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        allAnswers = Array(positiveAnswers) + Array(uncertainAnswers) + Array(negativeAnswers)
        
        getTimelineEntries(for: complication, before: Date(), limit: 1) {
            handler($0?.first)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // 1: Create an empty array to return
        var entries = [CLKComplicationTimelineEntry]()
        
        // 2: Create as many entries as requested
        for i in 0 ..< limit {
            print(limit)
            // 3: Calculate the date for this result
            let predictionDate = date.addingTimeInterval(Double(60 * 5 * i))
            
            // 4: Fetch a completed template for this date
            let predictionTemplate = template(for: complication.family, date: predictionDate)
            
            // 5: Add in the date
            let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)
            
            // 6: Append to our result array
            entries.append(entry)
        }
        
        // 7: Send back the timeline
        handler(entries)
    }
    
    // DEPRECATED
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries = [CLKComplicationTimelineEntry]()
        
        // note: reverse loop!
        for i in (0 ..< limit).reversed() {
            // note: reverse dates!
            let predictionDate = date.addingTimeInterval(Double(-60 * 5 * i))
            let predictionTemplate = template(for: complication.family, date: predictionDate)
            let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)
            entries.append(entry)
        }
        
        handler(entries)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Magic 8-Ball", shortText: "8-Ball"),
                body1TextProvider: CLKSimpleTextProvider(text: "Your Prediction", shortText: "Prediction")
            )
            handler(template)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: CLKSimpleTextProvider(text: "🎱"))
            handler(template)
        default:
            handler(nil)
        }
    }
    
    //
    
    func template(for family: CLKComplicationFamily, date: Date) -> CLKComplicationTemplate {
        // find the correct prediction for this date
        let predictionNumber = Int(date.timeIntervalSince1970) % allAnswers.count
        let prediction = allAnswers[predictionNumber]
        
        switch family {
        case .modularLarge:
            // create a long, text-based prediction
            let template = CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Magic 8-Ball"),
                body1TextProvider: CLKSimpleTextProvider(text: prediction)
            )
            return template
        default:
            // create a short, emoji-based prediction
            let template: CLKComplicationTemplateModularSmallSimpleText
            
            if positiveAnswers.contains(prediction) {
                template = .init(textProvider: CLKSimpleTextProvider(text: "😀"))
            } else if uncertainAnswers.contains(prediction) {
                template = .init(textProvider: CLKSimpleTextProvider(text: "🤔"))
            } else {
                template = .init(textProvider: CLKSimpleTextProvider(text: "😧"))
            }
            
            return template
        }
    }
}
