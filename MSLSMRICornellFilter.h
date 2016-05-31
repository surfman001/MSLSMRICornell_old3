//
//  MSLSMRICornellFilter.h is the plugin entry of Multiple Sclerosis Lesion Segmentation, is design by MRI lab of Cornell University.
//  MSLSMRICornell
//
//  Copyright (c) 2016 Rijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>
#import "SetWindowController.h"
#import "ProjectDebug.h"
@interface MSLSMRICornellFilter : PluginFilter {

}
// Plugin entrance

- (long) filterImage:(NSString*) menuName;

// Object of MSLSMERICornellFilter, reference to Brain Jensen

+ (id) getControllerForMainViewer:(ViewerController*) mViewer registeredViewer:(ViewerController*) rViewer;

@end
