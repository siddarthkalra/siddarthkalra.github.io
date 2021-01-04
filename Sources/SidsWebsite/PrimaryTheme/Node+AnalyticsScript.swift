//
//  Node+AnalyticsScript.swift
//  
//
//  Created by Siddarth Kalra on 2021-01-04.
//

import Plot

extension Node where Context == HTML.HeadContext {
    static func analyticsScript() -> Node {
        .script(
            .async(),
            .src("//gc.zgo.at/count.js"),
            .attribute(named: "data-goatcounter", value: "https://siddarthkalra.goatcounter.com/count")
        )
    }
}
