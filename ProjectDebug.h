//
//  ProjectDebug.h
//  MSLSMRICornell
//
//  Created by RijianSu on 5/20/16.
//
//

#ifndef MSLSMRICornell_ProjectDebug_h
#define MSLSMRICornell_ProjectDebug_h


#endif
#import <Foundation/NSDebug.h>

#define ITKNS nmITK

//Make sure debug output is enabled when compiling in development mode, and activated in deployment mode when NSDebugEnabled is set
#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#define DebugEnable(...) __VA_ARGS__
#else
#define DebugLog(...) if(NSDebugEnabled) NSLog(__VA_ARGS__)
#define DebugEnable(...) if(NSDebugEnabled) __VA_ARGS__
#endif



