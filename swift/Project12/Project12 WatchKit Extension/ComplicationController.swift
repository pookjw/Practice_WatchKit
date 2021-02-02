//
//  ComplicationController.swift
//  Project12 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/2/21.
//

import ClockKit

/// 6번
class ComplicationController: NSObject, CLKComplicationDataSource {
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Project12", supportedFamilies: [.modularSmall])
        ]
        handler(descriptors)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let currentText = UserDefaults.standard.string(forKey: "complication_number") ?? "❤️"
        let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: CLKTextProvider(format: currentText))
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: CLKTextProvider(format: "💔"))
        handler(template)
    }
}
