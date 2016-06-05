//
//  SetWindowController.h
//  MSLSMRICornell
//
//  Created by RijianSu on 5/20/16.
//
//

#import <Cocoa/Cocoa.h>
#import "OsiriXAPI/ViewerController.h"
#import <OsiriXAPI/PluginFilter.h>

@class ITKRegionGrowing3D;

@interface SetWindowController : NSWindowController{
        ViewerController	*viewer;
    
    ViewerController *mainViewer, *registeredViewer;
	//ITKRegionGrowing3D* segmenter;
    bool seedPointSelected;
    //Viewer box
	IBOutlet NSTextField* mainViewerLabel;
	IBOutlet NSTextField* regViewerLabel;
	IBOutlet NSButton *showSeedButton;
	IBOutlet NSButton *showMaxRegionButton;
	IBOutlet NSTextField *seedLabel;
	IBOutlet NSButton *enableRegViewerButton;
	IBOutlet NSButton *disableClickButton;
	int posX, posY, posZ,sliceNumber,lesionSerialNumber;
	float mmPosX, mmPosY, mmPosZ;
	float intensityValue;
	
	//Parameters box
	IBOutlet NSBox* paramsBox;
    IBOutlet NSTextField *sliceSerialNumber;
	NSArray	*algorithms;
	IBOutlet NSPopUpButton* algorithmPopUp;
	IBOutlet NSTabView* parameterView;
	IBOutlet NSTextField* lowerThresholdBox;
	IBOutlet NSTextField* upperThresholdBox;
	IBOutlet NSMatrix* manualRadioGroup;
	IBOutlet NSSlider* cutOffSlider;
	IBOutlet NSTextField* cutOffBox;
	IBOutlet NSTextField* searchRegionBox;
	IBOutlet NSTextField *nhRadiusX, *nhRadiusY, *nhRadiusZ;
    
    
	IBOutlet NSTextField* confMultBox;
	IBOutlet NSTextField *confNeighborhood;
	IBOutlet NSTextField *confIterationsBox;
	
	IBOutlet NSTextField* gradientBox;
	IBOutlet NSSlider* gradientSlider;
	IBOutlet NSTextField* gradientMaxSegmentationBox;
	float lowerThreshol, upperThreshold;
	
	//results box
	IBOutlet NSTextField* roiNameBox;
	IBOutlet NSColorWell* colorBox;
}
@property (readonly) ViewerController* mainViewer;
@property (readonly) ViewerController* registeredViewer;

@property (nonatomic, readwrite) int posX;
@property (nonatomic, readwrite) int posY;
@property (nonatomic, readwrite) int posZ;
@property (nonatomic, readwrite) int sliceNumber;
@property (nonatomic, readwrite) int lesionSerialNumber;
@property (nonatomic, readwrite) float mmPosX;
@property (nonatomic, readwrite) float mmPosY;
@property (nonatomic, readwrite) float mmPosZ;
@property (nonatomic, readwrite) float intensityValue;


/**
 *	Instantiates the class, loads the window nib file, and creates the segmentation object for the viewer combination
 */
- (id) initWithMainViewer:(ViewerController*) mViewer registeredViewer:(ViewerController*) rViewer;

/**
 *	Returns a dictionary with the factory defaults used by the application
 */
- (NSMutableDictionary*) getDefaults;
- (void) fillAlgorithmsPopUp;

/**
 *	Method triggered by one of the viewers, should close the window associated with this controller
 */
- (void) CloseViewerNotification:(NSNotification*) note;

/**
 *	Called by the main viewer when the user has clicked in the window
 */
- (void) mouseViewerDown:(NSNotification*) note;

/**
 *	Triggers the segmentation
 */
- (IBAction) calculate: (id) sender;

/**
 *	Called when the user switched between manual and cut off based thresholding
 */
- (IBAction) manualRadioSelChanged:(id) sender;

/**
 *	Called after the user changes the cut off percent, or the user has selected a new seed point
 */
- (IBAction) updateThresholds:(id) sender;

/**
 *	Triggered after the user has changed whether the registered viewer is used for segmentation or not
 */
- (IBAction) updateRegEnabled:(id) sender;

/**
 * Causes the parameters tab view to change and the window to resize
 */
- (IBAction) updateAlgorithm:(id) sender;

/**
 * Removes all the ROIs associated with the max search region, called upon intialization and after the user selects a new seed point
 */
- (void) removeMaxRegionROI;

/**
 * Removes all the ROIs associated with seed selection, called upon initialization and after the user selects a new seed point
 */
- (void) removeSeedPointROI;

/**
 *	Triggers the Max region ROI to be show or deletee, depending upon the user's selection
 */
- (IBAction) showMaxRegionEnable:(id) sender;

/**
 *	Triggers the Seed point ROI to be shown or deleted, depending upon the user's selection
 */
- (IBAction) showSeedEnable:(id) sender;

/**
 *	Resets all of the User defaults used by the application to be reset to our internal factory defaults
 */
- (IBAction) resetDefaults:(id) sender;
- (ViewerController*) viewer;

@end
