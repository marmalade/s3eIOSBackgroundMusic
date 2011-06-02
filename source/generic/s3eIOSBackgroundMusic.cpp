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
/*
Generic implementation of the s3eIOSBackgroundMusic extension.
This file should perform any platform-indepedentent functionality
(e.g. error checking) before calling platform-dependent implementations.
*/

/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */


#include "s3eIOSBackgroundMusic_internal.h"

s3eResult s3eIOSBackgroundMusicPickMusicItems(s3eBool allowMultipleItems, int buttonX, int buttonY, uint buttonWidth, uint buttonHeight, int desiredPosition, s3eBool canBeDismissed)
{
	return s3eIOSBackgroundMusicPickMusicItems_platform(allowMultipleItems, buttonX, buttonY, buttonWidth, buttonHeight, desiredPosition, canBeDismissed);
}

s3eResult s3eIOSBackgroundMusicSetInt(s3eIOSBackgroundMusicProperty property, int32 value)
{
	return s3eIOSBackgroundMusicSetInt_platform(property, value);
}

int32 s3eIOSBackgroundMusicGetInt(s3eIOSBackgroundMusicProperty property)
{
	return s3eIOSBackgroundMusicGetInt_platform(property);
}

struct s3eIOSBackgroundMusicItem* s3eIOSBackgroundMusicGetCurrentItem()
{
	return s3eIOSBackgroundMusicGetCurrentItem_platform();
}

s3eResult s3eIOSBackgroundMusicPlay()
{
	return s3eIOSBackgroundMusicPlay_platform();
}

s3eResult s3eIOSBackgroundMusicPause()
{
	return s3eIOSBackgroundMusicPause_platform();
}

s3eResult s3eIOSBackgroundMusicStop()
{
	return s3eIOSBackgroundMusicStop_platform();
}

s3eResult s3eIOSBackgroundMusicBeginSeekingForward()
{
	return s3eIOSBackgroundMusicBeginSeekingForward_platform();
}

s3eResult s3eIOSBackgroundMusicBeginSeekingBackward()
{
	return s3eIOSBackgroundMusicBeginSeekingBackward_platform();
}

s3eResult s3eIOSBackgroundMusicEndSeeking()
{
	return s3eIOSBackgroundMusicEndSeeking_platform();
}

s3eResult s3eIOSBackgroundMusicSkipToNextItem()
{
	return s3eIOSBackgroundMusicSkipToNextItem_platform();
}

s3eResult s3eIOSBackgroundMusicSkipToBeginning()
{
	return s3eIOSBackgroundMusicSkipToBeginning_platform();
}

s3eResult s3eIOSBackgroundMusicSkipToPreviousItem()
{
	return s3eIOSBackgroundMusicSkipToPreviousItem_platform();
}

const char* s3eIOSBackgroundMusicItemGetString(struct s3eIOSBackgroundMusicItem* item, s3eIOSBackgroundMusicItemProperty property)
{
	return s3eIOSBackgroundMusicItemGetString_platform(item, property);
}

int32 s3eIOSBackgroundMusicItemGetInt(struct s3eIOSBackgroundMusicItem* item, s3eIOSBackgroundMusicProperty property)
{
	return s3eIOSBackgroundMusicItemGetInt_platform(item, property);
}

int32 s3eIOSBackgroundMusicGetCollections(struct s3eIOSBackgroundMusicCollection** collections, int32 maxCollections, s3eIOSBackgroundMusicGroupingType groupingType, struct s3eIOSBackgroundMusicFilterPredicate** musicPropertyFilter, int numPredicates)
{
	return s3eIOSBackgroundMusicGetCollections_platform(collections, maxCollections, groupingType, musicPropertyFilter, numPredicates);
}

void s3eIOSBackgroundMusicReleaseCollection(struct s3eIOSBackgroundMusicCollection* collection)
{
	s3eIOSBackgroundMusicReleaseCollection_platform(collection);
}

int32 s3eIOSBackgroundMusicCollectionGetInt(struct s3eIOSBackgroundMusicCollection* collection, s3eIOSBackgroundMusicCollectionProperty property)
{
	return s3eIOSBackgroundMusicCollectionGetInt_platform(collection, property);
}

int32 s3eIOSBackgroundMusicCollectionGetItems(struct s3eIOSBackgroundMusicCollection* collection, struct s3eIOSBackgroundMusicItem** items, int32 maxItems)
{
	return s3eIOSBackgroundMusicCollectionGetItems_platform(collection, items, maxItems);
}

struct s3eIOSBackgroundMusicCollection* s3eIOSBackgroundMusicAppendCollection(struct s3eIOSBackgroundMusicCollection* firstCollection, struct s3eIOSBackgroundMusicCollection* secondCollection)
{
	return s3eIOSBackgroundMusicAppendCollection_platform(firstCollection, secondCollection);
}

s3eResult s3eIOSBackgroundMusicCreateCollection(struct s3eIOSBackgroundMusicItem** items, int itemCount)
{
	return s3eIOSBackgroundMusicCreateCollection_platform(items, itemCount);
}

s3eResult s3eIOSBackgroundMusicSetPlaybackQueueWithCollection(struct s3eIOSBackgroundMusicCollection* collection, s3eBool appendToExisting)
{
	return s3eIOSBackgroundMusicSetPlaybackQueueWithCollection_platform(collection, appendToExisting);
}

void s3eIOSBackgroundMusicTerminate()
{
	s3eIOSBackgroundMusicTerminate_platform();
}
