//
//  SetWindowController.m
//  MSLSMRICornell
//
//  Created by RijianSu on 5/20/16.
//
//
#import "MSLSMRICornellFilter.h"
#import "SetWindowController.h"
#import "OsiriXAPI/ROI.h"
#include "itkImage.h"
#include "itkImportImageFilter.h"
#include "itkBinaryThresholdImageFilter.h"

typedef     float itkPixelType;
typedef     itk::Image< itkPixelType, 2 > ImageType;
typedef     itk::ImportImageFilter< itkPixelType, 2 > ImportFilterType;
typedef     itk::BinaryThresholdImageFilter<ImageType, ImageType>  BinaryThresholdImageFilterType;

//Default ROI color
static char color_default[] = {0x04, 0x0b, 0x73, 0x74, 0x72, 0x65, 0x61, 0x6d, 0x74, 0x79, 0x70, 0x65};
   // 0x64, 0x81, 0xe8, 0x03, 0x84, 0x01, 0x40, 0x84, 0x84, 0x84, 0x07, 0x4e, 0x53, 0x43, 0x6f, 0x6c,
  //  0x6f, 0x72, 0x00, 0x84, 0x84, 0x08, 0x4e, 0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x00, 0x85,
  //  0x84, 0x01, 0x63, 0x01, 0x84, 0x04, 0x66, 0x66, 0x66, 0x66, 0x83, 0x4e, 0x5a, 0xda, 0x3d, 0x83,
  ///*  0x26, 0xeb, 0x36, 0x3e, 0x83, 0x6d, 0x0a, 0x63, 0x3f, 0x01, 0x86};

@implementation SetWindowController

@synthesize mainViewer, registeredViewer;
@synthesize posX, posY, posZ,sliceNumber,lesionSerialNumber;
@synthesize mmPosX, mmPosY, mmPosZ;
@synthesize intensityValue;




- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        NSLog(@"initwithwindows");
        // Initialization code here.
    }
    return self;
}
- (id) initWithMainViewer:(ViewerController*) mViewer registeredViewer:(ViewerController*) rViewer
{
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:[self getDefaults]];
	
	self = [super initWithWindowNibName:@"SetWindowController"];
	if(self != nil)
	{

		mainViewer = mViewer;
		registeredViewer = rViewer;
		seedPointSelected = NO;


		
		[self showWindow:self];
NSLog(@"dispinitmainviewer");
		if(registeredViewer != nil)
        {
            NSLog(@"only for test31");

        }
		else
        {
            NSLog(@"only for test32");
			//segmenter = [[ITKRegionGrowing3D alloc] initWithViewer:mainViewer];
        }
		
		[mainViewerLabel setStringValue:[[mainViewer window] title]];
		
		if(registeredViewer != nil)
		{
			[regViewerLabel setStringValue:[[registeredViewer window] title]];
		}
		else
		{
			[enableRegViewerButton setState:NSOffState];
			[enableRegViewerButton setEnabled:NO];
		}
		
		//remove any haning ROIs
		[self removeMaxRegionROI];
		[self removeSeedPointROI];
		
		//make sure we catch the necessary notifications
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver: self
			   selector: @selector(mouseViewerDown:)
				   name: @"mouseDown"
				 object: nil];
		
		[nc addObserver: self
			   selector: @selector(CloseViewerNotification:)
				   name: @"CloseViewerNotification"
				 object: nil];
        
		algorithms = [NSArray arrayWithObjects: @"Connected Threshold",
					  @"Neighborhood Connected",
					  @"Confidence Connected",
					  @"Gradient Thresholding",
					  nil];
		
		//initialize the rest of the interface (fill algorithm pop up, set correct tab)
		[self fillAlgorithmsPopUp];
		[self updateAlgorithm:self];
		[self manualRadioSelChanged:self];
		
	}
	else
		NSLog(@"Error loading the region growing window nib!");
	
	return self;

}
/*- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}*/

- (NSMutableDictionary*) getDefaults
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setValue:@"MS lesions Region" forKey:@"MSSegRoiLabel"];
	[defaults setValue:@"45.0"	forKey:@"NMSegCutOffPercent"];
	[defaults setValue:@"70.0"	forKey:@"NMSegSearchRegion"];
	[defaults setValue:@"1"		forKey:@"NMSegNHRadiusX"];
	[defaults setValue:@"1"		forKey:@"NMSegNHRadiusY"];
	[defaults setValue:@"1"		forKey:@"NMSegNHRadiusZ"];
	[defaults setValue:@"1"		forKey:@"NMSegManualSeg"];
	[defaults setValue:@"0"		forKey:@"NMSegAlgorithm"];
	[defaults setValue:@"2"		forKey:@"NMSegConfRadiusX"];
	[defaults setValue:@"2"		forKey:@"NMSegConfRadiusY"];
	[defaults setValue:@"2"		forKey:@"NMSegConfRadiusZ"];
	[defaults setValue:@"2.5"	forKey:@"NMSegConfMultiplier"];
	[defaults setValue:@"5"		forKey:@"NMSegConfIterations"];
	[defaults setValue:@"8.0"	forKey:@"NMSegGradient"];
	[defaults setValue:@"30"	forKey:@"NMSegMaxVolumeSize"];
	[defaults setValue:@"1"		forKey:@"NMSegShowSeed"];
	[defaults setValue:@"1"		forKey:@"NMSegShowMaxRegion"];
	[defaults setValue:@"1"		forKey:@"NMSegDisableClick"];
	[defaults setValue:[NSData dataWithBytes:color_default length:71] forKey:@"MSSegColor"];
    
	return defaults;
}


- (void) fillAlgorithmsPopUp
{
	unsigned int i;
	NSMenu *items = [[[NSMenu alloc] initWithTitle:@""] autorelease];
	
	for (i=0; i<[algorithms count]; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle: [algorithms objectAtIndex: i]];
		[item setTag:i];
		[items addItem:item];
	}
	
	[algorithmPopUp removeAllItems];
	[algorithmPopUp setMenu:items];
	[algorithmPopUp selectItemAtIndex:[[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"NMSegAlgorithm"] intValue]];
    
}

- (void) dealloc
{
	[super dealloc];
}

- (IBAction) manualRadioSelChanged:(id) sender
{
    
	//deactivate certain options depending upon the user's selection
	if([manualRadioGroup selectedRow] == 0)
	{
		[lowerThresholdBox setEnabled:YES];
		[upperThresholdBox setEnabled:YES];
		[cutOffBox setEnabled:NO];
		[cutOffSlider setEnabled:NO];
		[searchRegionBox setEnabled:NO];
	}
	else
	{
		[lowerThresholdBox setEnabled:NO];
		[upperThresholdBox setEnabled:NO];
		[cutOffBox setEnabled:YES];
		[cutOffSlider setEnabled:YES];
		[searchRegionBox setEnabled:YES];
	}
	
	[self updateThresholds:self];	//make sure the upper and lower thresholds get recalculated
}

- (void) CloseViewerNotification:(NSNotification*) note
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self close];
}

- (void) mouseViewerDown:(NSNotification*) note
{
	int xpx, ypx, zpx; // coordinate in pixels
	float xmm, ymm, zmm; // coordinate in millimeters
    
	//Disable the source viewer controller from reacting to the click events
	if([disableClickButton state] == NSOnState){
		[[note userInfo] setValue: [NSNumber numberWithBool: YES] forKey: @"stopMouseDown"];
	}
	else
	{
		return;
	}
	
	if([note object] == mainViewer)
	{
		[seedLabel setStringValue:@"selected (click to reselect)"];	//notify the user that the seed point was selected
        
		if([enableRegViewerButton state] == NSOnState)
		{
            NSLog(@"regview is enable");
			NSPoint np;
			np.x = [[[note userInfo] objectForKey:@"X"] intValue];
			np.y = [[[note userInfo] objectForKey:@"Y"] intValue];
			 zpx = [[registeredViewer imageView] curImage];
            
			np = [[mainViewer imageView] ConvertFromGL2GL:np toView:[registeredViewer imageView]];
			xpx = np.x;
			ypx = np.y;
			
			float location[3];
			[[[registeredViewer imageView] curDCM] convertPixX: (float) xpx pixY: (float) ypx toDICOMCoords: (float*) location pixelCenter: YES];
			xmm = location[0];
			ymm = location[1];
			zmm = location[2];
			[self setIntensityValue:[[[registeredViewer imageView] curDCM] getPixelValueX: xpx Y:ypx]];
            
		}
		else
		{

			xpx = [[[note userInfo] objectForKey:@"X"] intValue];
			ypx = [[[note userInfo] objectForKey:@"Y"] intValue];
			zpx = [[mainViewer imageView] curImage];
			
			float location[3];
			[[[mainViewer imageView] curDCM] convertPixX: (float) xpx pixY: (float) ypx toDICOMCoords: (float*) location pixelCenter: YES];
			xmm = location[0];
			ymm = location[1];
			zmm = location[2];
			
			[self setIntensityValue:[[[mainViewer imageView] curDCM] getPixelValueX: xpx Y:ypx]];
			
		}
		
		[self setPosX:xpx];
		[self setPosY:ypx];
		[self setPosZ:zpx];
        [self setSliceNumber:[[mainViewer pixList] count]-zpx];
        //sliceNumber= [[mainViewer imageView] curImage];
		[self setMmPosX:xmm];
		[self setMmPosY:ymm];
		[self setMmPosZ:zmm];
		
		seedPointSelected = YES;
		
		[self showSeedEnable:self];
		[self updateThresholds:self];
	}
}

- (IBAction) updateThresholds:(id) sender
{

	
	if([[algorithmPopUp selectedItem] tag] < 2 && [manualRadioGroup selectedRow] == 1 && seedPointSelected)
	{
		int displayIndex[2], searchIndex[3];
		int displayRegion[3], searchRegion[3];
		float displaySpacing[3], searchSpacing[3];
        
		DCMPix* curPix;
		int count;
        
		if([enableRegViewerButton state] == NSOnState)
		{
			curPix = [[registeredViewer imageView] curDCM];
			count = [[registeredViewer pixList] count];
		}
		else
		{
			curPix = [[mainViewer imageView] curDCM];
			count = [[mainViewer pixList] count];
		}
		
		searchSpacing[0] = [curPix pixelSpacingX];
		searchSpacing[1] = [curPix pixelSpacingY];
		searchSpacing[2] = [curPix sliceInterval];
        
		searchRegion[0] = [searchRegionBox floatValue] / searchSpacing[0];
		searchRegion[1] = [searchRegionBox floatValue] / searchSpacing[1];
		searchRegion[2] = [searchRegionBox floatValue] / searchSpacing[2];
        
		searchIndex[0] = [self posX] - (searchRegion[0] / 2);
		searchIndex[1] = [self posY] - (searchRegion[1] / 2);
		searchIndex[2] = [self posZ] - (searchRegion[2] / 2);
        
		//Make sure we don't go out of the image's domain
		if(searchIndex[0] < 0)
		{
			searchRegion[0] += searchIndex[0];
			searchIndex[0] = 0;
		}
		else if(searchIndex[0] > [curPix pwidth])
		{
			searchRegion[0] = 0;
			searchIndex[0] = [curPix pwidth];
		}
		
		if(searchIndex[1] < 0)
		{
			searchRegion[1] += searchIndex[1];
			searchIndex[1] = 0;
		}
		else if(searchIndex[1] > [curPix pheight])
		{
			searchRegion[1] = 0;
			searchIndex[1] = [curPix pheight];
		}
		
		if(searchIndex[2] < 0)
		{
			searchRegion[2] += searchIndex[2];
			searchIndex[2] = 0;
		}
		else if(searchIndex[2] > count )
		{
			searchRegion[2] = 0;
			searchIndex[2] = count;
		}
		
		if(searchIndex[0] + searchRegion[0] > [curPix pwidth])
			searchRegion[0] = [curPix pwidth] - searchIndex[0];
		else if(searchRegion[0] < 0)
			searchRegion[0] = 0;
        
		if(searchIndex[1] + searchRegion[1] > [curPix pheight])
			searchRegion[1] = [curPix pheight] - searchIndex[1];
		else if(searchRegion[1] < 0)
			searchRegion[1] = 0;
		
		if(searchIndex[2] + searchRegion[2] > count)
			searchRegion[2] = count - searchIndex[2];
		else if(searchRegion[2] < 0)
			searchRegion[2] = 0;
		
		NSLog(@"max search region sizes: %d %d %d", searchRegion[0], searchRegion[1], searchRegion[2]);
        NSLog(@"max search region index: %d %d %d", searchIndex[0], searchIndex[1], searchIndex[2]);
        
		if([enableRegViewerButton state] == NSOnState)
		{
			//convert the search indexes into the main viewer's parameter space
			NSPoint np = NSMakePoint(searchIndex[0], searchIndex[1]);
			curPix = [[mainViewer imageView] curDCM];
			displaySpacing[0] = [curPix pixelSpacingX];
			displaySpacing[1] = [curPix pixelSpacingY];
			displaySpacing[2] = [curPix sliceInterval];
            
			displayRegion[2] = [searchRegionBox floatValue] / displaySpacing[2];
			
			np = [[registeredViewer imageView] ConvertFromGL2GL:np toView:[mainViewer imageView]];
			displayIndex[0] = np.x;
			displayIndex[1] = np.y;
			
			np.x = searchIndex[0] + searchRegion[0];
			np.y = searchIndex[1] + searchRegion[1];
			
			np = [[registeredViewer imageView] ConvertFromGL2GL:np toView:[mainViewer imageView]];
            
			displayRegion[0] = np.x - displayIndex[0];
			displayRegion[1] = np.y - displayIndex[1];
			
            
		}
		else
		{
			displayRegion[0] = searchRegion[0];
			displayRegion[1] = searchRegion[1];
			displayRegion[2] = searchRegion[2];
            
			displayIndex[0] = searchIndex[0];
			displayIndex[1] = searchIndex[1];
		}
		
		NSLog(@"display search region sizes: %d %d %d", displayRegion[0], displayRegion[1], displayRegion[2]);
		NSLog(@"display search region index: %d %d", displayIndex[0], displayIndex[1]);
        
//		float maxVal = [segmenter findMaximum:searchIndex region:searchRegion];
//		DebugLog(@"Max value in region %f", maxVal);
//		[upperThresholdBox setFloatValue:maxVal];
        
		if([showMaxRegionButton state] == NSOnState)
		{
			//now add the ROI to the image slice
			NSMutableArray  *roiSeriesList;
			NSMutableArray  *roiImageList;
			roiSeriesList = [mainViewer roiList];
            
			[self removeMaxRegionROI];
            
			int sliceStart = [[mainViewer imageView] curImage] - (displayRegion[2] / 2);
			if(sliceStart < 0)
				sliceStart = 0;
            
			for(unsigned int sliceIndex = sliceStart; sliceIndex < (unsigned int) sliceStart + displayRegion[2]; sliceIndex++)
			{
				if(sliceIndex >= [[mainViewer pixList] count])
					break;
				
				roiImageList = [roiSeriesList objectAtIndex:sliceIndex];
				ROI *myROI = [mainViewer newROI:tROI];
				NSRect rect = NSMakeRect(displayIndex[0], displayIndex[1], displayRegion[0], displayRegion[1]);
				[myROI setName:@"Max Threshold Localization Region"];
				[myROI setROIRect:rect];
				[roiImageList addObject: myROI];
			}
            
			[[mainViewer imageView] roiSet];
		}
        
		float lowerThreshold = ([cutOffBox floatValue] * [upperThresholdBox floatValue] / 100);
		[lowerThresholdBox setFloatValue:lowerThreshold];
	}
}

- (IBAction) updateRegEnabled:(id) sender
{
	if([enableRegViewerButton state] == NSOnState && registeredViewer != nil)
    {
        NSLog(@"add this sentense just only for test SVC");
        NSLog(@"only for test1");
		//[segmenter setRegViewer:registeredViewer];
    }
	else
    {
        NSLog(@"only for test2");
		//[segmenter removeRegViewer];
    }
}

- (IBAction) calculate: (id) sender
{
	
    NSLog(@"Calculate segmentation trigerred");
	int seed[3], radius[3], iterations = 0;
   
	
	if([[algorithmPopUp selectedItem] tag] == 1)
	{
		radius[0] = [nhRadiusX intValue];
		radius[1] = [nhRadiusY intValue];
		radius[2] = [nhRadiusZ intValue];
	}
	else if([[algorithmPopUp selectedItem] tag] == 2)
	{
		radius[0] = [confNeighborhood intValue];
		iterations = [confIterationsBox intValue];
	}
	else if([[algorithmPopUp selectedItem] tag] == 3)
	{
		iterations = [gradientMaxSegmentationBox intValue];
	}
	
	seed[0] = [self posX];
	seed[1] = [self posY];
	seed[2] = [self posZ];
//	[self setSliceNumber:[[mainViewer pixList] count]-posZ];
	[self removeMaxRegionROI];
	[self removeSeedPointROI];
	
	NSLog([roiNameBox stringValue]);
	/* [segmenter		regionGrowing:-1
					seedPoint:seed
                         name:[roiNameBox stringValue]
                        color:[colorBox color]
              algorithmNumber:[[algorithmPopUp selectedItem] tag]
               lowerThreshold:[lowerThresholdBox floatValue]
               upperThreshold:[upperThresholdBox floatValue]
                       radius:radius
               confMultiplier:[confMultBox floatValue]
                   iterations:iterations
                     gradient:[gradientBox floatValue]
     ];*/
    
    // we want to desplay results in new viewer, so we duplicate current
        // we will loop over slice and time dimention (in 4d viewer)
    DCMPix      *firstPix = [[mainViewer imageView] curDCM];
    
    int         times= [[mainViewer pixList] count];
    int         slices = [mainViewer maxMovieIndex];
    int         lowerThreshold = 6, upThreshold = 100;
    
//     NSLog(@"times are %i, slices are %i",times,slices);
//    slices = [[viewer imageView] curImage];
//    NSLog(@"viewertimes are %i, slices are %i",times,slices);
//    slices = [[mainViewer imageView] curImage];
//    NSLog(@"mainViewertimes are %i, slices are %i",times,slices);
//    slices = [[registeredViewer imageView] curImage];
    NSLog(@"mainViewertimes are %i, slices are %i",times,slices);
    // ITK initialization
    BinaryThresholdImageFilterType::Pointer thresholdFilter = BinaryThresholdImageFilterType::New();
    ImportFilterType::Pointer importFilter = ImportFilterType::New();
    
    // settings needed in ITK import filter
    ImportFilterType::IndexType start;
    start[0] = 0;
    start[1] = 0;
    float maxIntensityValue = 65536.0;
    ImportFilterType::SizeType size;
    size[0] = [firstPix pwidth];
    size[1] = [firstPix pheight];
    long bufferSize = size[0] * size[1];
    float imageIntensity[size[1]][size[0]], signImage[size[1]][size[0]];
    float temporarySignImage[size[1]][size[0]];
    //float segmentationImage[size[0]][size[1]];
    float labelCurrentMean = 0,labelCurrentSTD;
    int deltaFactor = 30;
    int deltaValue;
    int deltaHead = 1;
    int deltaEnd;
    int deltaMid;
    BOOL indicator = YES, flagHead = YES, flagMid = YES, flagEnd = YES;
    float currentThreshold;
    int seedSearchDown = -6;
    int seedSearchUp = 6;
    int searchDown = -1;
    int searchUp = 1;
    int stackSeed[bufferSize][2];
    stackSeed[0][0]=seed[0];
    stackSeed[0][1]=seed[1];
    long int stackStart = 0;
    long int stackEnd = 0;
    long unsigned currentX = stackSeed[stackStart][0];
    long unsigned currentY = stackSeed[stackStart][1];
    long int labelCount = 0;
    float seedIntensityValue;
    while (indicator)
    {
        indicator = NO;
        if (flagHead)
        {
            flagHead = NO;

            for (int i=0; i<=size[0]; i++)
            {
                for (int j=0; j<=size[1]; j++)
                {
                    temporarySignImage[i][j] = 0.0;
                }
            }
           
            if (fabs(temporarySignImage[seed[0]][seed[1]])<0.1)
            {
                [self setIntensityValue:[[[mainViewer imageView] curDCM] getPixelValueX: seed[0] Y:seed[1]]];
                temporarySignImage[seed[1]][seed[0]] = intensityValue;
                seedIntensityValue = intensityValue;
                
                currentThreshold = intensityValue;
                labelCount++;
                
                for (int m=seedSearchDown; m<=seedSearchUp; m++)
                {
                    
                    for (int n=seedSearchDown; n<=seedSearchUp; n++)
                    {
                        [self setIntensityValue:[[[mainViewer imageView] curDCM] getPixelValueX: (currentX+m) Y:(currentY+n)]];
                        float currentIntensityValue;
                        currentIntensityValue = intensityValue;
                        if (temporarySignImage[currentY+n][currentX+m]==0.0&&fabsf(currentIntensityValue-seedIntensityValue)<=(seedIntensityValue/10))
                        {
                        
                            
                            currentIntensityValue = intensityValue;
                            if (fabsf(seedIntensityValue-currentIntensityValue)<=currentThreshold&&(currentX+m)<=size[0]&&(currentX+m)>=1&&(currentY+n)<=size[1]&&(currentY+n)>=1&&temporarySignImage[currentY+n][currentX+m]<0.1&&currentIntensityValue<maxIntensityValue&&currentIntensityValue>0)
                            // the pixel is inside the border
                            // rule1=(CurrX+m)<=Width&(CurrX+m)>=1&(CurrY+n)<=Height&(CurrY+n)>=1;
                            // //if the pixel is be labeled
                            // rule2=sign_image(CurrX+m,CurrY+n)==0;
                            // //if the gray value less than threshold
                            // rule3=abs(double(image(CurrX,CurrY))-double(image(CurrX+m,CurrY+n)))<Threshold;
                            // //rule=(rule1&rule2&rule3)
                            
                            
                            {
                                
                                stackEnd++;
                                stackSeed[stackEnd][0]=currentX+m; //push the new pixel in the queue
                                stackSeed[stackEnd][1]=currentY+n;
                                //NSLog(@"stackEnd=%li, curx=%d,cury=%d",stackEnd,stackSeed[stackEnd][0],stackSeed[stackEnd][1]);
                                temporarySignImage[currentY+n][currentX+m] = currentIntensityValue;
                                labelCount++;
                            }
                        }

                    }
                    
                }
                int i=0;
                float localSum = 0.0;
                for (int m=seedSearchDown; m<=seedSearchUp; m++)
                {
                    for (int n=seedSearchDown; n<=seedSearchUp; n++)
                    {
                        if (fabsf(temporarySignImage[currentY+n][currentX+m])>0.01)
                        {
                            i++;
                            localSum = localSum + temporarySignImage[currentY+n][currentX+m];
                            
                        }
                    }
                }
                
                labelCurrentMean = localSum/i;
                localSum = 0.0;
                for (int m=seedSearchDown; m<=seedSearchUp; m++)
                {
                    for (int n=seedSearchDown; n<=seedSearchUp; n++)
                    {
                        if (fabsf(temporarySignImage[currentY+n][currentX+m])>0.01)
                        {
                            i++;
                            float temp=temporarySignImage[currentY+n][currentX+m]-labelCurrentMean;
                            
                            localSum = localSum + pow(temp,2.0);
                            
                        }
                    }
                }
                labelCurrentSTD = localSum/i;
                currentThreshold = labelCurrentMean/6;
                NSLog(@"labelCurrentMean is %f,currentThreshold is %f",labelCurrentMean,currentThreshold);
                stackStart++;
                while(stackStart<=stackEnd)         //there is one pixel, which isn't dealed with, at least
                {
                    
                    currentX=stackSeed[stackStart][0];  //coordinate of current coordinate
                    currentY=stackSeed[stackStart][1];
                    //NSLog(@"currentX,currentY=(%lu,%lu)",currentX,currentY);
                    for (int m=searchDown;m<=searchUp;m++)                      //ergodic 8 pixel nearby the current coordinate ????8???
                    {
                        for (int n=searchDown;n<=searchUp;n++)
                        {
                            [self setIntensityValue:[[[mainViewer imageView] curDCM] getPixelValueX: (currentX+m) Y:(currentY+n)]];
                            float currentIntensityValue;
                            currentIntensityValue = intensityValue;
                            if (temporarySignImage[currentY+n][currentX+m]==0.0&&fabsf(currentIntensityValue-seedIntensityValue)<=(labelCurrentSTD))
                            {

                                [self setIntensityValue:[[[mainViewer imageView] curDCM] getPixelValueX: currentX Y:currentY]];
                                float newSeedIntensityValue=intensityValue;//the name of variable is seedIntensityValue, it it change in fact.
                
                
                                if ((currentX+m)<=size[0]&&(currentX+m)>=1&&(currentY+n)<=size[1]&&(currentY+n)>=1&&fabsf(temporarySignImage[currentY+n][currentX+m])<0.1&&fabsf(newSeedIntensityValue-currentIntensityValue)<=currentThreshold&&currentIntensityValue<maxIntensityValue&&currentIntensityValue>0)
                                {
                            
                                    // NSLog(@"found the pixel");
                                    stackEnd++;
                                    stackSeed[stackEnd][0]=currentX+m; //push the new pixel in the queue
                                    stackSeed[stackEnd][1]=currentY+n;
                                    // NSLog(@"stackEnd=%li, curx=%d,cury=%d",stackEnd,stackSeed[stackEnd][0],stackSeed[stackEnd][1]);
                                    temporarySignImage[currentY+n][currentX+m] = currentIntensityValue;
                                    labelCount = labelCount + 1;
                                }
                            }
                        }
                    }
                
                
                //                currentThreshold = mean2(temporarySignImage(temporarySignImage~=0))/delta(j);
                    stackStart++;
                }
            }
        }
    }
                //thresholdAll(deltaHead) = currentThreshold;
               // labelAllCount(deltaHead) = labelCount;                 //different threshold responsble for pixels
               // labelAllMean(deltaHead) = labelCurrentMean;
               // tempImagehead = temporarySignImage;         //temporary image of head element
                
        
                
                
                

                
        
/*            for (int i=0; i<=size[0]; i++)
            {
                for (int j=0; j<=size[1]; j++)
                {
                    NSLog(@"temp(%i,%i)=%f",i,j, temporarySignImage[i][j]) ;
                }
            }*/
            
        
    
    
 /*
    ImportFilterType::RegionType region;
    double  origin[2];
    double  voxelSpacing[2];
    
    origin[0] = [firstPix originX];
    origin[1] = [firstPix originY];
    
    voxelSpacing[0] = [firstPix pixelSpacingX];
    voxelSpacing[1] = [firstPix pixelSpacingY];
    
    region.SetIndex(start);
    region.SetSize(size);
    
    // apply settings to ITK import filter
    importFilter->SetRegion(region);
    importFilter->SetOrigin(origin);
    importFilter->SetSpacing(voxelSpacing);
    
    // apply settings to ITK threshold filter
    thresholdFilter->SetLowerThreshold(lowerThreshold);
    thresholdFilter->SetUpperThreshold(upThreshold);
    thresholdFilter->SetInsideValue(90);
    thresholdFilter->SetOutsideValue(-1000);
    
    
    // loop over all images
    for (int s=0; s<slices; s++)
    {
        NSMutableArray *PixList = [mainViewer pixList:s];
        
        for (int t=0; t<times; t++){
            
            // get image from viewer
            DCMPix *pix = [PixList objectAtIndex:t];
            
            // pass it to import filter
            importFilter->SetImportPointer([pix fImage], bufferSize, false);
            
            // use threshold filter
            thresholdFilter->SetInput(importFilter->GetOutput());
            thresholdFilter->Update();
            
            // get result buffer
            float* resultBuff = thresholdFilter->GetOutput()->GetBufferPointer();
            
            long mem = bufferSize * sizeof(float);
            
            // copy result to current pix
            memcpy( [[[mainViewer pixList:s] objectAtIndex:t] fImage], resultBuff, mem);
        }
    }
    //test the intensityValue in the region from (120, 260) to (140, 280)
    for (int xcc=120; xcc<140; xcc++)
        for (int ycc=260; ycc<280; ycc++) {
            [self setIntensityValue:[[[registeredViewer imageView] curDCM] getPixelValueX: xcc Y:ycc]];
            NSLog(@"(%i,%i)= %f",xcc,ycc,intensityValue);

        }
  
    for (int i=0; i<=size[0]; i++)
    {
        for (int j=0; j<=size[1]; j++)
        {
            NSLog(@"temp(%i,%i)=%f",i,j, temporarySignImage[i][j]) ;
        }
    }*/
  //  NSMutableArray *PixList = [mainViewer pixList:0];
  //  int t = [[mainViewer imageView] curImage];
    // DCMPix *pix = [PixList objectAtIndex:t];
    //importFilter->SetImportPointer([pix fImage], bufferSize, false);
    //thresholdFilter->SetInput(importFilter->GetOutput());
    //thresholdFilter->Update();
    //float* resultBuff = thresholdFilter->GetOutput()->GetBufferPointer();
/*    float * resultBuff;
    resultBuff = &temporarySignImage[0][0];
    long mem = bufferSize * sizeof(float);
    
    // copy result to current pix
    memcpy( [[[mainViewer pixList:0] objectAtIndex:t] fImage], resultBuff, mem);*/
   // [self setIntensityValue:[[[mainViewer imageView] curDCM] getPixelValueX: seed[0] Y:seed[1]]];
    for (int i=0; i<=size[0]; i++)
    {
        for (int j=0; j<=size[1]; j++)
        {
            if(temporarySignImage[i][j] > 0.01f)
            {
                [[[mainViewer imageView] curDCM] setPixelX:j Y:i value:6255];
                NSLog(@"tem(%i,%i)=%f",i,j,temporarySignImage[j][i]);

            }
        }
    }
    [mainViewer needsDisplayUpdate];
    

}

- (void) removeMaxRegionROI
{
	NSLog(@"Removing Max search region ROI");
	NSMutableArray *roiSeriesList = [mainViewer roiList];
	
	for(NSMutableArray* roiImageList in roiSeriesList)
	{
		for(unsigned int index = 0; index < [roiImageList count]; index++)
		{
			ROI *roi = [roiImageList objectAtIndex:index];
			if([[roi name] compare:@"Max Threshold Localization Region"] == NSOrderedSame)
			{
				[roiImageList removeObject:roi];
			}
		}
	}
	
	[[mainViewer imageView] roiSet];
}

- (IBAction) showMaxRegionEnable:(id) sender
{
	if([showMaxRegionButton state] == NSOnState)
		[self updateThresholds:sender];
	else
		[self removeMaxRegionROI];
	
	[mainViewer needsDisplayUpdate];
}

- (void) removeSeedPointROI
{
	NSLog(@"Removing Seed ROI");
	NSMutableArray *roiSeriesList = [mainViewer roiList];
	for(NSMutableArray* roiImageList in roiSeriesList)
	{
		for(unsigned int index = 0; index < [roiImageList count]; index++)
		{
			ROI *roi = [roiImageList objectAtIndex:index];
			if([[roi name] compare:@"Segmentation Seed Point"] == NSOrderedSame)
			{
				[roiImageList removeObject:roi];
			}
		}
	}
}


- (IBAction) showSeedEnable:(id) sender
{
	NSLog(@"Setting seed point");
	[self removeSeedPointROI];
	
	if([showSeedButton state] == NSOnState)
	{
		NSLog(@"Displaying seed point ROI");
		NSMutableArray *roiSeriesList = [mainViewer roiList];
		NSRect rect;
		
		if([enableRegViewerButton state] == NSOnState)
		{
			NSPoint np = NSMakePoint([self posX], [self posY]);
			np = [[registeredViewer imageView] ConvertFromGL2GL:np toView:[mainViewer imageView]];
			rect = NSMakeRect(np.x, np.y, 1, 1);
		}
		else
		{
			rect = NSMakeRect([self posX], [self posY], 1, 1);
		}
		
		NSMutableArray *roiImageList = [roiSeriesList objectAtIndex:[[mainViewer imageView] curImage]];
		ROI *myROI = [mainViewer newROI:t2DPoint];
		[myROI setName:@"Segmentation Seed Point"];
		[myROI setROIRect:rect];
		[roiImageList addObject: myROI];
	}
    
	[[mainViewer imageView] roiSet];
	[mainViewer needsDisplayUpdate];
}

- (IBAction) updateAlgorithm:(id) sender;
{
	NSLog(@"NMRegionGrowingController: algorithm selection changed");
	NSMenuItem* item = [algorithmPopUp selectedItem];
	
	if([item tag] < 2)
	{
		NSLog(@"Displaying Connected / neighbor parameters panel");
		//first resize the window, then switch the view
		NSRect r = [[self window] frame];
		r.size.height = 650; //Size in IB plus 16px title
		[[self window] setFrame:r display:YES animate:YES];
		r = [paramsBox frame];
		r.size.height = 238; //Size in IB plus 16px title
		[paramsBox setFrame:r];
		
		[parameterView selectTabViewItemAtIndex:0];
		
		if([item tag] == 1)
		{
			[nhRadiusX setEnabled:YES];
			[nhRadiusY setEnabled:YES];
			[nhRadiusZ setEnabled:YES];
		}
		else
		{
			[nhRadiusX setEnabled:NO];
			[nhRadiusY setEnabled:NO];
			[nhRadiusZ setEnabled:NO];
		}
        
		[showMaxRegionButton setEnabled:YES];
		[self manualRadioSelChanged:self];
		[self showMaxRegionEnable:self];
		[self showSeedEnable:self];		//redraw the max seed point
	}
	else if([item tag] == 2)
	{
		NSLog(@"Displaying Confidence parameters panel");
		//first switch the view, then resize the window
		[parameterView selectTabViewItemAtIndex:1];
		
		NSRect r = [paramsBox frame];
		r.size.height = 138; //Size in IB plus title - 100
		[paramsBox setFrame:r];
		r = [[self window] frame];
		r.size.height = 550; //Size in IB plus titls - 100
		[[self window] setFrame:r display:YES animate:YES];
		
		[showMaxRegionButton setEnabled:NO];
		[self removeMaxRegionROI];
		
		[self showSeedEnable:self];		//redraw the max seed point
		[mainViewer needsDisplayUpdate];
	}
	else		//current only 4 items
	{
		NSLog(@"Displaying gradient parameters panel");
		//first switch the view, then resize the window
		[parameterView selectTabViewItemAtIndex:2];
		
		NSRect r = [paramsBox frame];
		r.size.height = 108; //Size in IB plus title - 130
		[paramsBox setFrame:r];
		r = [[self window] frame];
		r.size.height = 520; //Size in IB plus titls - 130
		[[self window] setFrame:r display:YES animate:YES];
		
		[showMaxRegionButton setEnabled:NO];
		[self removeMaxRegionROI];
		
		[self showSeedEnable:self];		//redraw the max seed point
		[mainViewer needsDisplayUpdate];
	}
	
}

- (IBAction) resetDefaults:(id) sender
{
	NSLog(@"Revert to default parameters requested");
	int selection = NSRunAlertPanel(@"Revert to Defaults", @"Do you really want to revert to the default paramters?", @"Yes", @"No", NULL);
	
	if(selection == 1)	//first reset the defaults dictionary, then reset the interface
	{
		[[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:[self getDefaults]];
		NSLog(@"NMRegionGrowingController: Reverting to factory defaults");
		[algorithmPopUp selectItemAtIndex:[[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"NMSegAlgorithm"] intValue]];
		[self updateAlgorithm:self];
		[self manualRadioSelChanged:self];
		[self updateThresholds:self];
        
	}
}

- (ViewerController*) viewer
{
	return viewer;
}

@end
