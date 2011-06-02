/*
 * Copyright (C) 2001-2011 Ideaworks3D Ltd.
 * All Rights Reserved.
 *
 * This document is protected by copyright, and contains information
 * proprietary to Ideaworks Labs.
 * This file consists of source code released by Ideaworks Labs under
 * the terms of the accompanying End User License Agreement (EULA).
 * Please do not use this program/source code before you have read the
 * EULA and have agreed to be bound by its terms.
 */
#define IW_USE_SYSTEM_STDLIB
#include "s3eEdk.h"
#include "s3eEdk_iphone.h"
#include "s3eSurface.h"
#include "IwDebug.h"
#include <unistd.h>
#include "s3eIOSBackgroundMusic_internal.h"
#include "s3eIOSBackgroundMusic_autodefs.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MPMediaPickerController.h>

#define S3E_CURRENT_EXT IOSBACKGROUNDMUSIC
#include "s3eEdkError.h"

#define S3E_DEVICE_IOSBACKGROUNDMUSIC S3E_EXT_IOSBACKGROUNDMUSIC_HASH

typedef enum IPodPickerStatus
{
    IPOD_STATUS_NONE,
    IPOD_STATUS_RUNNING,
    IPOD_STATUS_SUCCESS,
    IPOD_STATUS_ERROR,
} IPodPickerStatus;

static IPodPickerStatus g_IPodPickerStatus = IPOD_STATUS_NONE;

/*static bool g_IPodPickerActive = false;
@interface s3eMediaPickerController : MPMediaPickerController
- (void)viewDidDisappear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewDidUnload:(BOOL)animated;
@end

@implementation s3eMediaPickerController

- (void)viewDidDisappear:(BOOL)animated;
{
    IwTrace(BACKGROUNDMUSIC, ("s3eMediaPickerController viewDidDisappear"));
    g_IPodPickerActive = false;
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
    IwTrace(BACKGROUNDMUSIC, ("s3eMediaPickerController viewDidAppear"));
    [super viewDidAppear:animated];
}

- (void)viewDidUnload:(BOOL)animated;
{
    IwTrace(BACKGROUNDMUSIC, ("s3eMediaPickerController viewDidUnload"));
}
@end*/

@interface s3eMediaPickerDelegate : NSObject <MPMediaPickerControllerDelegate>
{
}
@end

// Media picker globals - Only g_Popover really needs to be global (and maybe could be a member of g_delegate...)
// since it needs to be got when the media picker closes via touching "done".
s3eMediaPickerDelegate* g_MediaPickerDelegate = 0;
static UIPopoverController* g_Popover = 0;

@interface s3ePopoverDelegate : NSObject <UIPopoverControllerDelegate>
{
    BOOL m_CanBeDismissed;
}
@property BOOL m_CanBeDismissed;
@end

@implementation s3ePopoverDelegate

@synthesize m_CanBeDismissed;

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return m_CanBeDismissed;
}

// Only called when popover is dismissed by touching away from it...
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    IwTrace(EXT, ("popoverControllerDidDismissPopover"));

    g_IPodPickerStatus = IPOD_STATUS_ERROR;
    S3E_EXT_ERROR_SIMPLE(CANCELLED);
    
    popoverController.delegate = nil;
    
    [g_MediaPickerDelegate release];
    g_MediaPickerDelegate = 0;
    
    // release popover and delegate
    [popoverController release];
    g_Popover = 0; // == popoverController, maybe dont need these globals at all since this is all modal one way or other...
    [self release];
}
@end


static void* _s3eLaunchIPodApp_real(bool allowMultipleItems, bool isIPad, bool usePopoverForIPad, int nativeOriginX, int nativeOriginY, uint nativeW, uint nativeH, int desiredPosition, bool canBeDismissed)
{
    IwTrace(BACKGROUNDMUSIC, ("_s3eLaunchIPodApp_real start"));

    g_MediaPickerDelegate = [[s3eMediaPickerDelegate alloc] init];
    MPMediaPickerController* g_MediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    g_MediaPicker.delegate = g_MediaPickerDelegate;
    
    IwTrace(BACKGROUNDMUSIC, ("g_MediaPicker=%p g_MediaPickerDelegate=%p", g_MediaPicker, g_MediaPickerDelegate));
    
    if (allowMultipleItems)
    {
        // On ipad, there is an apparent OS bug that if the prompt is displayed, the frame for the list of
        // items overlaps the songs/artists/etc title. Changing popover size doent fix this so disabling it.
        if (!usePopoverForIPad)
            g_MediaPicker.prompt = @"Select tracks to play";
        
        g_MediaPicker.allowsPickingMultipleItems = YES;
    }
    else
    {
        if (!usePopoverForIPad)
            g_MediaPicker.prompt = @"Select a track to play";
        
        g_MediaPicker.allowsPickingMultipleItems = NO;
    }
    
    //[UIDevice currentDevice].proximityMonitoringEnabled = NO;
    
    if (usePopoverForIPad)
    {
        IwTrace(BACKGROUNDMUSIC, ("Using popover for media picker"));

        // Init a Popover controller using the media picker as its root view controller
        g_Popover = [[UIPopoverController alloc] initWithContentViewController:g_MediaPicker];
        s3ePopoverDelegate* delegate = [[s3ePopoverDelegate alloc] init];
        delegate.m_CanBeDismissed = canBeDismissed;
        g_Popover.delegate = delegate;
        
        // NB: Specifing size of popover just changes frame size, not picker. Picker always uses default of 320x460
        //[g_Popover setPopoverContentSize:CGSizeMake(x, y,) animated:YES];

        // Popovers are invoked from centre of a dummy rectangle
        CGRect popOverRect = CGRectMake(nativeOriginX, nativeOriginY, nativeW, nativeH);
        
        // Display the popover
        UIView* currentView;
        if (s3eEdkGetGLUIView())
            currentView = s3eEdkGetGLUIView();
        else
            currentView = s3eEdkGetSurfaceUIView();
        
        // s3e picker positions map directly to ios arrow directions
        [g_Popover presentPopoverFromRect:popOverRect inView:currentView permittedArrowDirections:desiredPosition animated:YES];
    }
    else
    {
        // iOS 3.2+ goes full screen (or popovers on ipad at native res) and wont show status bar, 3.1 needs to show status (using old 3.1 method) as it leaves a gap for it
        if (!isIPad && s3eEdkIPhoneGetVerMaj() < 4)
            [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
        
        [s3eEdkGetUIViewController() presentModalViewController:g_MediaPicker animated:YES];
    }
    
    [g_MediaPicker release];
    
    IwTrace(BACKGROUNDMUSIC, ("_s3eLaunchIPodApp_real done"));
    return 0;
}

S3E_BEGIN_C_DECL 


s3eResult _s3eLaunchIPodApp(s3eBool allowMultipleItems, int buttonX, int buttonY, uint buttonWidth, uint buttonHeight, int desiredPosition, s3eBool canBeDismissed)
{
    IwTrace(BACKGROUNDMUSIC, ("Launching iPod App"));

    // Safety check - dont allow to run twice (unlikley)
    if (g_IPodPickerStatus != IPOD_STATUS_NONE || g_Popover)
        return S3E_RESULT_ERROR;
    
    // this variable is used to signal when the user has exited the iPod app
    g_IPodPickerStatus = IPOD_STATUS_RUNNING;
    //g_IPodPickerActive = true;
    
    // On iPad, using modal view controller results in parts of screen being unresponsive since the picker
    // is not designed to run on so large an area. Official recommendation is to display using a popover view.
    // Use normal behaviour if running in iphone emulation/2x zoom mode (smaller screen)
    bool isIPad = s3eEdkDeviceIsAnIPad();
    bool usePopoverForIPad = (isIPad && s3eSurfaceGetInt(S3E_SURFACE_DEVICE_HEIGHT) > 480);

    int nativeOriginX = 0;
    int nativeOriginY = 0;
    int nativeOriginW = 0;
    int nativeOriginH = 0;
    
    // direct comparison with these #defines results in e.g. 15 > 15 being true, even when casting to int32..!
    int32 maxPos = (int32)S3E_IOSBACKGROUNDMUSIC_PICKER_POSITION_ANY;
    int32 minPos = (int32)S3E_IOSBACKGROUNDMUSIC_PICKER_POSITION_UP;
    
    if (desiredPosition < minPos || desiredPosition > maxPos)
    {
        S3E_EXT_ERROR(PARAM, ("desiredPosition (%d) must be a valid mask of Background Music Picker Position values", desiredPosition));
        return S3E_RESULT_ERROR;
    }
    
    if (!buttonWidth || !buttonHeight)
    {
        S3E_EXT_ERROR(PARAM, ("button has zero dimension"));
        return S3E_RESULT_ERROR;
    }

    if (usePopoverForIPad)
    {
        // Need to specify an origin rectangle for popover to point to. Uses rect rather than point to adjust
        // pointer to avoid text etc - easier to leave OS to do that for us.

        // Default to centred in x and offset by a bit more than half UI height in y to centre the UI on screen.
        if (buttonX == -1) buttonX = s3eSurfaceGetInt(S3E_SURFACE_WIDTH)/2 - (buttonWidth/2);
        if (buttonY == -1) buttonY = s3eSurfaceGetInt(S3E_SURFACE_HEIGHT)/2 + 260;

        int deviceWidth = s3eSurfaceGetInt(S3E_SURFACE_DEVICE_WIDTH);
        int deviceHeight = s3eSurfaceGetInt(S3E_SURFACE_DEVICE_HEIGHT);

        // Native coordinates are fixed from top left corner as the parent view never rotates.
        // Have to account for s3eSurface or IwGx so must use DEVICE height and width and do rotation ourselves
        // (user/surface height width does not change on rotation when using Gx)
        switch ((s3eSurfaceBlitDirection)s3eSurfaceGetInt(S3E_SURFACE_DEVICE_BLIT_DIRECTION))
        {
            case S3E_SURFACE_BLIT_DIR_ROT90:
                nativeOriginX = deviceWidth - buttonY - buttonHeight;
                nativeOriginY = buttonX;
                nativeOriginW = buttonHeight;
                nativeOriginH = buttonWidth;
                break;
            case S3E_SURFACE_BLIT_DIR_ROT180:
                nativeOriginX = deviceWidth - buttonX - buttonWidth;
                nativeOriginY = deviceHeight - buttonY - buttonHeight;
                nativeOriginW = buttonWidth;
                nativeOriginH = buttonHeight;
                break;
            case S3E_SURFACE_BLIT_DIR_ROT270:
                nativeOriginX = buttonY;
                nativeOriginY = deviceHeight - buttonX - buttonWidth;
                nativeOriginW = buttonHeight;
                nativeOriginH = buttonWidth;
                break;
            default:
                nativeOriginX = buttonX;
                nativeOriginY = buttonY;
                nativeOriginW = buttonWidth;
                nativeOriginH = buttonHeight;
        }

        if (nativeOriginX > deviceWidth || nativeOriginY > deviceHeight || nativeOriginX+nativeOriginW < 0 || nativeOriginY+nativeOriginH < 0)
        {
            S3E_EXT_ERROR(PARAM, ("button position is off-screen"));
            return S3E_RESULT_ERROR;
        }
    }

    s3eEdkThreadRunOnOS((s3eEdkThreadFunc)_s3eLaunchIPodApp_real, 9, allowMultipleItems, isIPad, usePopoverForIPad, nativeOriginX, nativeOriginY, nativeOriginW, nativeOriginH, desiredPosition, canBeDismissed);
    
    IwTrace(BACKGROUNDMUSIC, ("waiting for iPod App to complete"));

    s3eEdkThreadSetSuspended(); //Indicate that we're blocked
    
    while (g_IPodPickerStatus == IPOD_STATUS_RUNNING && !s3eEdkIsTerminating())
        usleep(10000);

    s3eEdkThreadSetResumed();
    
    IwTrace(BACKGROUNDMUSIC, ("iPod App complete: %d %d", g_IPodPickerStatus, s3eEdkIsTerminating()));
    
    // Return status bar to prev orientation as it can rotate during picker display and get stuck in wrong orientation
    s3eEdkUpdateStatusBarOrient();
    
    if (g_IPodPickerStatus == IPOD_STATUS_ERROR)
    {
        g_IPodPickerStatus = IPOD_STATUS_NONE;
        return S3E_RESULT_ERROR;
    }
    
    g_IPodPickerStatus = IPOD_STATUS_NONE;
    return S3E_RESULT_SUCCESS;
}

S3E_END_C_DECL

@implementation s3eMediaPickerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection 
{
    IwTrace(EXT, ("didPickMediaItems"));

    if (!g_Popover)
    {
        if (s3eEdkIPhoneGetVerMaj() < 4 && !s3eEdkDeviceIsAnIPad())
            [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        
        [s3eEdkGetUIViewController() dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [g_Popover dismissPopoverAnimated:NO]; // this does NOT cause popoverControllerDidDismissPopover to be called
        s3ePopoverDelegate* delegate = g_Popover.delegate;
        g_Popover.delegate = nil;
        [g_Popover release];
        g_Popover = 0;
        [delegate release];
    }
    
    // play chosen items
    MPMusicPlayerController *iPodController = [MPMusicPlayerController iPodMusicPlayer];
    [iPodController setQueueWithItemCollection:mediaItemCollection];
    [iPodController play];
    
    g_IPodPickerStatus = IPOD_STATUS_SUCCESS;
    
    mediaPicker.delegate = nil;
    [self release];
    g_MediaPickerDelegate = 0;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker 
{
    IwTrace(EXT, ("mediaPickerDidCancel"));

    if (!g_Popover)
    {
        if (s3eEdkIPhoneGetVerMaj() < 4 && !s3eEdkDeviceIsAnIPad())
            [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        
        [s3eEdkGetUIViewController() dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [g_Popover dismissPopoverAnimated:NO]; // does NOT cause popoverControllerDidDismissPopover to be called
        s3ePopoverDelegate* delegate = g_Popover.delegate;
        g_Popover.delegate = nil;
        [g_Popover release];
        g_Popover = 0;
        [delegate release];
    }
    
    g_IPodPickerStatus = IPOD_STATUS_ERROR;
    S3E_EXT_ERROR_SIMPLE(CANCELLED);
    
    mediaPicker.delegate = nil;
    [self release];
    g_MediaPickerDelegate = 0;
}
@end
