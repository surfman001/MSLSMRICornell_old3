//
//  MSLesionSeed.h
//  MSLSMRICornell
//
//  Created by RijianSu on 6/5/16.
//
//

#import <Foundation/Foundation.h>

@interface MSLesionSeed : NSObject{
    int sliceSerialNumber;
    int lesionSerialNumber;
    int seedCoordinatX;
    int seedCoordinatY;
    
}
@property (readwrite) int sliceSerialNumber;
@property (readwrite) int lesionSerialNumber;
@property (readwrite) int seedCoordinatX;
@property (readwrite) int seedCoordinatY;
+ (void) addSeed:(MSLesionSeed *)seed;

@end
