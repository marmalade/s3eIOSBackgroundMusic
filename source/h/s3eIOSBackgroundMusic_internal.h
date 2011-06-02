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
#ifndef S3E_BACKGROUND_MUSIC_INTERNAL_H
#define S3E_BACKGROUND_MUSIC_INTERNAL_H

#include "s3eTypes.h"
#include "s3eIOSBackgroundMusic.h"
#include "s3eIOSBackgroundAudio.h"
#include "IwArray.h"

//#ifdef I3D_OS_IPHONE
struct s3eIOSBackgroundMusicCollection
{
	s3eIOSBackgroundMusicGroupingType  m_groupingType;
	void*          m_objCCollection;
};
//#endif // ifdef I3D_OS_IPHONE

S3E_BEGIN_C_DECL

s3eResult s3eIOSBackgroundMusicPickMusicItems_platform(s3eBool allowMultipleItems, int buttonX, int buttonY, uint buttonWidth, uint buttonHeight, int desiredPosition, s3eBool canBeDismissed);
s3eResult s3eIOSBackgroundMusicSetInt_platform(s3eIOSBackgroundMusicProperty property, int32 value);
int32 s3eIOSBackgroundMusicGetInt_platform(s3eIOSBackgroundMusicProperty property);
struct s3eIOSBackgroundMusicItem* s3eIOSBackgroundMusicGetCurrentItem_platform();
s3eResult s3eIOSBackgroundMusicPlay_platform();
s3eResult s3eIOSBackgroundMusicPause_platform();
s3eResult s3eIOSBackgroundMusicStop_platform();
s3eResult s3eIOSBackgroundMusicBeginSeekingForward_platform();
s3eResult s3eIOSBackgroundMusicBeginSeekingBackward_platform();
s3eResult s3eIOSBackgroundMusicEndSeeking_platform();
s3eResult s3eIOSBackgroundMusicSkipToNextItem_platform();
s3eResult s3eIOSBackgroundMusicSkipToBeginning_platform();
s3eResult s3eIOSBackgroundMusicSkipToPreviousItem_platform();
const char* s3eIOSBackgroundMusicItemGetString_platform(struct s3eIOSBackgroundMusicItem* item, s3eIOSBackgroundMusicItemProperty property);
int32 s3eIOSBackgroundMusicItemGetInt_platform(struct s3eIOSBackgroundMusicItem* item, s3eIOSBackgroundMusicProperty property);
int32 s3eIOSBackgroundMusicGetCollections_platform(struct s3eIOSBackgroundMusicCollection** collectionSet, int32 maxCollections, s3eIOSBackgroundMusicGroupingType groupingType, struct s3eIOSBackgroundMusicFilterPredicate** musicPropertyFilter, int numPredicates);
void s3eIOSBackgroundMusicReleaseCollection_platform(struct s3eIOSBackgroundMusicCollection* collection);
int32 s3eIOSBackgroundMusicCollectionGetInt_platform(struct s3eIOSBackgroundMusicCollection* collection, s3eIOSBackgroundMusicCollectionProperty property);
int32 s3eIOSBackgroundMusicCollectionGetItems_platform(struct s3eIOSBackgroundMusicCollection* collection, struct s3eIOSBackgroundMusicItem** items, int32 maxItems);
struct s3eIOSBackgroundMusicCollection* s3eIOSBackgroundMusicAppendCollection_platform(struct s3eIOSBackgroundMusicCollection* firstCollection, struct s3eIOSBackgroundMusicCollection* secondCollection);
s3eResult s3eIOSBackgroundMusicCreateCollection_platform(struct s3eIOSBackgroundMusicItem**, int itemCount);
s3eResult s3eIOSBackgroundMusicSetPlaybackQueueWithCollection_platform(struct s3eIOSBackgroundMusicCollection*, s3eBool appendToExisting);
void s3eIOSBackgroundMusicTerminate_platform();

s3eResult _s3eLaunchIPodApp(s3eBool allowMultipleItems, int buttonX, int buttonY, uint buttonWidth, uint buttonHeight, int desiredPosition, s3eBool canBeDismissed);

S3E_END_C_DECL

#endif // !S3E_BACKGROUND_MUSIC_INTERNAL_H
