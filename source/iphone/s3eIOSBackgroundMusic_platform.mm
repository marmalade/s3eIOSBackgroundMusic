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
#include "s3eIOSBackgroundMusic_internal.h"
#include "IwDebug.h"
#include "s3eEdk.h"
#include <vector>
#include <algorithm>

#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MPMediaPickerController.h>

#define S3E_CURRENT_EXT IOSBACKGROUNDMUSIC
#include "s3eEdkError.h"
#define S3E_DEVICE_IOSBACKGROUNDMUSIC S3E_EXT_IOSBACKGROUNDMUSIC_HASH

std::vector<s3eIOSBackgroundMusicCollection*> g_CollectionList;

s3eResult _s3eLaunchIPodApp(s3eBool allowMultipleItems, int buttonX, int buttonY, uint buttonWidth, uint buttonHeight, int desiredPosition, s3eBool canBeDismissed);

s3eResult s3eIOSBackgroundMusicPickMusicItems_platform(s3eBool allowMultipleItems, int buttonX, int buttonY, uint buttonWidth, uint buttonHeight, int desiredPosition, s3eBool canBeDismissed)
{
	return _s3eLaunchIPodApp(allowMultipleItems, buttonX, buttonY, buttonWidth, buttonHeight, desiredPosition, canBeDismissed);
}

s3eBool s3eIOSBackgroundAudioSetMix(s3eBool mix);
s3eBool	s3eIOSBackgroundAudioGetMix(void);

s3eBool s3eEdkBackgroundMusicAvailable()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	if (!iPod)
		return S3E_FALSE;
	return S3E_TRUE;
}

s3eResult s3eIOSBackgroundMusicSetInt_platform(s3eIOSBackgroundMusicProperty property, int32 value)
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];

	switch (property)
	{
		case S3E_IOSBACKGROUNDMUSIC_CURRENT_PLAYBACK_TIME:
		{
			NSTimeInterval timeInSeconds = 0.001 * (NSTimeInterval)value;
			
			iPod.currentPlaybackTime = timeInSeconds;
			break;
		}

		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_REPEAT_MODE:
		{
			switch (value)
			{
				case S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_DEFAULT:
					iPod.repeatMode = MPMusicRepeatModeDefault;
					break;					
					
				case S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_NONE:
					iPod.repeatMode = MPMusicRepeatModeNone;
					break;
					
				case S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_ONE:
					iPod.repeatMode = MPMusicRepeatModeOne;
					break;
					
				case S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_ALL:
					iPod.repeatMode = MPMusicRepeatModeAll;
					break;
					
				default:
					break;
			}
			break;
		}

		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_SHUFFLE_MODE:
		{
			switch (value)
			{
				case S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_DEFAULT:
					iPod.shuffleMode = MPMusicShuffleModeDefault;
					break;					
				
				case S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_OFF:
					iPod.shuffleMode = MPMusicShuffleModeOff;
					break;
				
				case S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_SONGS:
					iPod.shuffleMode = MPMusicShuffleModeSongs;
					break;
				
				case S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_ALBUMS:
					iPod.shuffleMode = MPMusicShuffleModeAlbums;
					break;
				
				default:
					break;
			}
			break;
		}
			
		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_VOLUME:
		{
			NSTimeInterval volume = ((NSTimeInterval)value) / 255.0;
			
			iPod.volume = volume;
			break;
		}
			
		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_MIX:
			s3eIOSBackgroundAudioSetMix(value);
			break;

		default:
			break;
	}

	return S3E_RESULT_ERROR;
}

int32 s3eIOSBackgroundMusicGetInt_platform(s3eIOSBackgroundMusicProperty property)
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	
	if (!iPod)
		return -1;	
	
	switch (property)
	{
		case S3E_IOSBACKGROUNDMUSIC_CURRENT_PLAYBACK_TIME:
		{
			NSTimeInterval	timeInSeconds = 1000.0 * (NSTimeInterval)iPod.currentPlaybackTime;
			
			return (int32)timeInSeconds;
		}
			
		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_STATE:
		{
			switch (iPod.playbackState)
			{
				case MPMusicPlaybackStateStopped:
					return S3E_IOSBACKGROUNDMUSIC_PLAYBACK_STOPPED;
					
				case MPMusicPlaybackStatePlaying:
					return S3E_IOSBACKGROUNDMUSIC_PLAYBACK_PLAYING;
					
				case MPMusicPlaybackStatePaused:
					return S3E_IOSBACKGROUNDMUSIC_PLAYBACK_PAUSED;
					
				case MPMusicPlaybackStateInterrupted:
					return S3E_IOSBACKGROUNDMUSIC_PLAYBACK_INTERRUPTED;
					
				case MPMusicPlaybackStateSeekingForward:
					return S3E_IOSBACKGROUNDMUSIC_PLAYBACK_SEEKING_FORWARD;
					
				case MPMusicPlaybackStateSeekingBackward:
					return S3E_IOSBACKGROUNDMUSIC_PLAYBACK_SEEKING_BACKWARD;	
					
				default:
					break;
			}
			break;
		}

		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_REPEAT_MODE:
		{
			switch (iPod.repeatMode)
			{
				case MPMusicRepeatModeDefault:
					return S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_DEFAULT;
				
				case MPMusicRepeatModeNone:
					return S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_NONE;
				
				case MPMusicRepeatModeOne:
					return S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_ONE;
				
				case MPMusicRepeatModeAll:
					return S3E_IOSBACKGROUNDMUSIC_REPEAT_MODE_ALL;					
					
				default:
					break;
			}
			break;
		}

		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_SHUFFLE_MODE:
		{
			switch (iPod.shuffleMode)
			{
				case MPMusicShuffleModeDefault:
					return S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_DEFAULT;
				
				case MPMusicShuffleModeOff:
					return S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_OFF;
				
				case MPMusicShuffleModeSongs:
					return S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_SONGS;
				
				case MPMusicShuffleModeAlbums:
					return S3E_IOSBACKGROUNDMUSIC_SHUFFLE_MODE_ALBUMS;
					
				default:
					break;
			}
			break;
		}

		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_VOLUME:
		{
			NSTimeInterval	volume = 255.0 * (NSTimeInterval)iPod.volume;
			
			return (int32)volume;
		}
			
		case S3E_IOSBACKGROUNDMUSIC_PLAYBACK_MIX:
			return s3eIOSBackgroundAudioGetMix();

		default:
			break;
	}	

	return -1;
}

struct s3eIOSBackgroundMusicItem* s3eIOSBackgroundMusicGetCurrentItem_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	return (struct s3eIOSBackgroundMusicItem*)iPod.nowPlayingItem;
}

s3eResult s3eIOSBackgroundMusicPlay_platform()
{
	IwTrace(BACKGROUNDMUSIC, ("BackgroundMusicPlay"));
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod play];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicPause_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod pause];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicStop_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod stop];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicBeginSeekingForward_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod beginSeekingForward];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicBeginSeekingBackward_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod beginSeekingBackward];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicEndSeeking_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod endSeeking];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicSkipToNextItem_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod skipToNextItem];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicSkipToBeginning_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod skipToBeginning];	
	return S3E_RESULT_SUCCESS;
}

s3eResult s3eIOSBackgroundMusicSkipToPreviousItem_platform()
{
	MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
	[iPod skipToPreviousItem];	
	return S3E_RESULT_SUCCESS;
}

static char gHexStringTemp[8 + 8 + 1]; 

const char* s3eIOSBackgroundMusicItemGetString_platform(struct s3eIOSBackgroundMusicItem* item, 
                                                     s3eIOSBackgroundMusicItemProperty property)
{
	if (!item)
		return 0;
	
	IwTrace(BACKGROUNDMUSIC_VERBOSE, ("BackgroundMusicItemGetString: %d", property));
	MPMediaItem*	mediaItem = (MPMediaItem*)item;	
	
	switch (property)
	{
		case S3E_IOSBACKGROUNDMUSICITEM_PERSISTENT_ID:
		{
			NSNumber*	value = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
			union {
				uint32	i[2];
				uint64	li;
			} u;
			
			if (!value)
				return 0;
			
			u.li = [value unsignedLongLongValue];
			
			snprintf(gHexStringTemp, sizeof(gHexStringTemp), "%08x%08x", u.i[0], u.i[1]);
			
			return gHexStringTemp;
		}			
			
		case S3E_IOSBACKGROUNDMUSICITEM_TITLE:
		{
			NSString*	value = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
			
			if (!value)
				return 0;
			
			return [value UTF8String];
		}
			
		case S3E_IOSBACKGROUNDMUSICITEM_ALBUM_TITLE:
		{
			NSString*	value = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
			
			if (!value)
				return 0;
			
			return [value UTF8String];
		}
			
		case S3E_IOSBACKGROUNDMUSICITEM_ARTIST:
		{
			NSString*	value = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
			
			if (!value)
				return 0;
			
			return [value UTF8String];
		}
			
		case S3E_IOSBACKGROUNDMUSICITEM_ALBUM_ARTIST:
		{
			NSString*	value = [mediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
			
			if (!value)
				return 0;
			
			return [value UTF8String];
		}
			
		case S3E_IOSBACKGROUNDMUSICITEM_GENRE:
		{
			NSString*	value = [mediaItem valueForProperty:MPMediaItemPropertyGenre];
			
			if (!value)
				return 0;
			
			return [value UTF8String];
		}
			
		case S3E_IOSBACKGROUNDMUSICITEM_COMPOSER:
		{
			NSString*	value = [mediaItem valueForProperty:MPMediaItemPropertyComposer];
			
			if (!value)
				return 0;
			
			return [value UTF8String];
		}	
			
		case S3E_IOSBACKGROUNDMUSICITEM_LYRICS:
		{
			NSString*	value = [mediaItem valueForProperty:MPMediaItemPropertyLyrics];
			
			if (!value)
				return 0;
			
			return [value UTF8String];
		}		
				
		default:
			break;
	}
	
	return 0;
}

int32 s3eIOSBackgroundMusicItemGetInt_platform(struct s3eIOSBackgroundMusicItem* item, 
											s3eIOSBackgroundMusicProperty property)
{
	IwTrace(BACKGROUNDMUSIC_VERBOSE, ("BackgroundMusicItemGetInt: %d", property));
	
	if (!item)
		return -1;
	
	MPMediaItem* mediaItem = (MPMediaItem*)item;	
	
	switch (property)
	{			
		case S3E_IOSBACKGROUNDMUSICITEM_MEDIA_TYPE:
		{
			NSInteger*	value = (NSInteger*)[mediaItem valueForProperty:MPMediaItemPropertyMediaType];
		
			if (!value)
				return -1;
			
			return *value;
		}		
		
		case S3E_IOSBACKGROUNDMUSICITEM_PLAYBACK_DURATION:
		{
			NSNumber*	value = [mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
			
			if (!value)
				return -1;		
			
			return (int32)(1000.0 * [value doubleValue]);
		}		
			
		case S3E_IOSBACKGROUNDMUSICITEM_ALBUM_TRACK_NUMBER:
		{
			NSUInteger*	value = (NSUInteger*)[mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
			if (!value)
				return -1;
			
			return *value;
		}	
			
		case S3E_IOSBACKGROUNDMUSICITEM_ALBUM_TRACK_COUNT:
		{
			NSUInteger*	value = (NSUInteger*)[mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackCount];
			if (!value)
				return -1;
			
			return *value;
		}	
			
		case S3E_IOSBACKGROUNDMUSICITEM_DISC_NUMBER:
		{
			NSUInteger*	value = (NSUInteger*)[mediaItem valueForProperty:MPMediaItemPropertyDiscNumber];
			if (!value)
				return -1;
			
			return *value;
		}	
			
		case S3E_IOSBACKGROUNDMUSICITEM_DISC_COUNT:
		{
			NSUInteger*	value = (NSUInteger*)[mediaItem valueForProperty:MPMediaItemPropertyDiscCount];
			if (!value)
				return -1;
			
			return *value;
		}
			
		case S3E_IOSBACKGROUNDMUSICITEM_IS_COMPILATION:
		{
			NSNumber*	value = [mediaItem valueForProperty:MPMediaItemPropertyIsCompilation];
			if (!value)
				return -1;		
			
			return [value boolValue] ? S3E_TRUE : S3E_FALSE;
		}	
			
		default:
			break;
	}
	
	return -1;
}

typedef enum ValueType
{
	_TYPE_INT,
	_TYPE_INT64,
	_TYPE_STRING
} ValueType;

int32 s3eIOSBackgroundMusicGetCollections_platform(struct s3eIOSBackgroundMusicCollection** collectionSet, int32 maxCollections, s3eIOSBackgroundMusicGroupingType groupingType, struct s3eIOSBackgroundMusicFilterPredicate** musicPropertyFilter, int numPredicates)
{
	if (!collectionSet || !maxCollections)
	{
		//error param
		return -1;
	}
	if (numPredicates && !musicPropertyFilter)
	{
		//error param
		return -1;
	}
	
	// Construct query/filter
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	
	for (int i=0; i < numPredicates; i++)
	{
		s3eIOSBackgroundMusicFilterPredicate* predicate = musicPropertyFilter[i];
		
		MPMediaPredicateComparison compType;
		if (predicate->m_comparisonType == S3E_IOSBACKGROUNDMUSIC_COMPARISON_CONTAINS)
			compType = MPMediaPredicateComparisonContains;
		else if (predicate->m_comparisonType == S3E_IOSBACKGROUNDMUSIC_COMPARISON_EQUAL_TO)
			compType = MPMediaPredicateComparisonEqualTo;
		else
		{
			// TODO: set error
			return -1;
		}
		
		ValueType valType = _TYPE_STRING;
		NSString* property;
		switch (predicate->m_property)
		{
			case S3E_IOSBACKGROUNDMUSICITEM_PERSISTENT_ID:
				property = MPMediaItemPropertyPersistentID;
				valType = _TYPE_INT64;
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_MEDIA_TYPE:
				property = MPMediaItemPropertyMediaType;
				valType = _TYPE_INT; // s3eIOSBackgroundMusicMediaType casts directly to MPMediaType* enum.
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_TITLE:
				property = MPMediaItemPropertyTitle;
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_ALBUM_TITLE:
				property = MPMediaItemPropertyAlbumTitle;
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_ARTIST:
				property = MPMediaItemPropertyArtist;
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_ALBUM_ARTIST:
				property = MPMediaItemPropertyAlbumArtist;
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_GENRE:
				property = MPMediaItemPropertyGenre;
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_COMPOSER:
				property = MPMediaItemPropertyComposer;
				break;
			case S3E_IOSBACKGROUNDMUSICITEM_IS_COMPILATION:
				property = MPMediaItemPropertyIsCompilation;
				valType = _TYPE_INT; //bool 1 or 0
				break;
			default:
				// TODO: set error
				return -1;
		}
		
		MPMediaPropertyPredicate* objCPredicate;
		if (valType == _TYPE_STRING)
		{
			objCPredicate = [MPMediaPropertyPredicate predicateWithValue: [NSString stringWithUTF8String:(char*)predicate->m_value]
															  forProperty: property];
																		    //comparisonType: compType];
		}
		//else if (valType = _TYPE_INT64)
		//
		else //_TYPE_INT
		{
			int valInt = *((int*)predicate->m_value);
			objCPredicate = [MPMediaPropertyPredicate predicateWithValue: [NSNumber numberWithInt:valInt]
															  forProperty: property];
																		    //comparisonType: compType];
		}
		
		[query addFilterPredicate: objCPredicate];
	}

	int32 returnCount = 0;
	
	if (groupingType == S3E_IOSBACKGROUNDMUSIC_GROUPING_NONE)
	{
		NSArray *items = [query items];
		
		if (!items)
		{
			//error device
			return -1;
		}
		if (![items count])
		{
			return 0;
		}
		
		MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:items];
		
		s3eIOSBackgroundMusicCollection* s3eCollection = (s3eIOSBackgroundMusicCollection*)s3eEdkMallocOS(sizeof(struct s3eIOSBackgroundMusicCollection), 0);
		s3eCollection->m_groupingType = groupingType;
		[collection retain];
		s3eCollection->m_objCCollection = collection;
		g_CollectionList.push_back(s3eCollection);
		
		// Pointer to return to app
		collectionSet[1] = s3eCollection;
		returnCount = 1;
	}
	else
	{
		MPMediaGrouping objCGroupingType;
		switch (groupingType)
		{
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_TITLE:
				objCGroupingType = MPMediaGroupingTitle;
				break;
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_ALBUM:
				objCGroupingType = MPMediaGroupingAlbum;
				break;
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_ARTIST:
				objCGroupingType = MPMediaGroupingArtist;
				break;
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_ALBUM_ARTIST:
				objCGroupingType = MPMediaGroupingAlbumArtist;
				break;
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_COMPOSER:
				objCGroupingType = MPMediaGroupingComposer;
				break;
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_GENRE:
				objCGroupingType = MPMediaGroupingGenre;
				break;
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_PLAYLIST:
				objCGroupingType = MPMediaGroupingPlaylist;
				break;
			case S3E_IOSBACKGROUNDMUSIC_GROUPING_PODCAST_TITLE:
				objCGroupingType = MPMediaGroupingPodcastTitle;
				break;
			//SeriesName is in iphone docs but not headers! Maybe will be added
			//case: S3E_IOSBACKGROUNDMUSIC_GROUPING_SERIES_NAME:
			//	objCGroupingType = MPMediaGroupingSeriesName;
			//	break;
			default:
				//TODO: error
				return -1;
		}
		
		[query setGroupingType: objCGroupingType];
		
		NSArray *collections = [query collections];
		
		if (!collections)
		{
			//error device
			return -1;
		}
		if (![collections count])
		{
			return 0;
		}
		
		returnCount = [collections count];
		
		// Limit to size of return array but still return actual amount so app can see it is short
		if (maxCollections > returnCount)
			maxCollections = returnCount;

		for (int i=0; i < maxCollections; i++) // or (MPMediaItemCollection *collection in collections)
		{
			MPMediaItemCollection* collection = [collections objectAtIndex:i];
			
			s3eIOSBackgroundMusicCollection* s3eCollection = (s3eIOSBackgroundMusicCollection*)s3eEdkMallocOS(sizeof(s3eIOSBackgroundMusicCollection), 0);
			s3eCollection->m_groupingType = groupingType;
			[collection retain];
			s3eCollection->m_objCCollection = collection;
			g_CollectionList.push_back(s3eCollection);
			
			// Pointer to return to app
			collectionSet[i] = s3eCollection;
			
			//TODO: want to add this as a property of a collection to get a descriptive bit of info
			//MPMediaItem *representativeItem = [album representativeItem];
		}
	}
	
	[query release];
	return returnCount;
}

void s3eIOSBackgroundMusicReleaseCollection_platform(struct s3eIOSBackgroundMusicCollection* collection)
{
	if (!collection)
		return;
	

	std::vector<s3eIOSBackgroundMusicCollection*>::iterator it = 
		find(g_CollectionList.begin(), g_CollectionList.end(), collection);
	if (it == g_CollectionList.end())
		return;

	g_CollectionList.erase(it);
	
	MPMediaItemCollection* objcCCollection = (MPMediaItemCollection*)collection->m_objCCollection;
	[objcCCollection release];
	s3eEdkFreeOS(collection);
}

int32 s3eIOSBackgroundMusicCollectionGetInt_platform(struct s3eIOSBackgroundMusicCollection* collection, s3eIOSBackgroundMusicCollectionProperty property)
{
	if (!collection || std::find(g_CollectionList.begin(), g_CollectionList.end(), collection) == g_CollectionList.end())
		return -1;
	
	MPMediaItemCollection* objcCCollection = (MPMediaItemCollection*)collection->m_objCCollection;
	
	switch (property)
	{
		case S3E_IOSBACKGROUNDMUSIC_COLLECTION_COUNT:
			return (int32)[objcCCollection count];
			
		case S3E_IOSBACKGROUNDMUSIC_COLLECTION_MEDIA_TYPES:
			return (int32)[objcCCollection mediaTypes];
			
		case S3E_IOSBACKGROUNDMUSIC_COLLECTION_GROUPING_TYPE:
			return (int32)collection->m_groupingType;
			
		default:
			return -1;
	}
}

int32 s3eIOSBackgroundMusicCollectionGetItems_platform(struct s3eIOSBackgroundMusicCollection* collection, struct s3eIOSBackgroundMusicItem** items, int32 maxItems)
{
	if (!collection || std::find(g_CollectionList.begin(), g_CollectionList.end(), collection) == g_CollectionList.end()
		 || !items || maxItems < 1)
		return -1;
	
	MPMediaItemCollection* objcCCollection = (MPMediaItemCollection*)collection->m_objCCollection;
	NSArray* objCItems = [objcCCollection items];
	
	if (!objCItems)
	{
		//error device
		return -1;
	}
	if (![objCItems count])
	{
		return -1; // shouldn't have retained a collection with zero items!
	}
	
	int32 returnCount = [objCItems count];
		
	// Limit to size of return array but still return actual amount so app can see it is short
	if (maxItems > returnCount)
		maxItems = returnCount;

	for (int i=0; i < maxItems; i++)
	{
		items[i] = (s3eIOSBackgroundMusicItem*)[objCItems objectAtIndex:i];
	}
	
	return returnCount;
}

struct s3eIOSBackgroundMusicCollection* s3eIOSBackgroundMusicAppendCollection_platform(struct s3eIOSBackgroundMusicCollection* firstCollection, struct s3eIOSBackgroundMusicCollection* secondCollection)
{
	return NULL;
}

s3eResult s3eIOSBackgroundMusicCreateCollection_platform(struct s3eIOSBackgroundMusicItem** items, int itemCount)
{
	// Needs consideration. Do we want to create new collections from items alsready associated with
	// another collection? Maybe copy them. Using int64 may be more useful here or a good alt function.
	return S3E_RESULT_ERROR;
}

s3eResult s3eIOSBackgroundMusicSetPlaybackQueueWithCollection_platform(struct s3eIOSBackgroundMusicCollection* collection, s3eBool appendToExisting)
{
	// TODO: need to implement seperate music player and pass the collection given here to it
	return S3E_RESULT_ERROR;
}

void s3eIOSBackgroundMusicTerminate_platform()
{
	for (std::vector<s3eIOSBackgroundMusicCollection*>::iterator i = g_CollectionList.begin(); i != g_CollectionList.end(); i++)
	{
		MPMediaItemCollection* objcCCollection = (MPMediaItemCollection*)(*i)->m_objCCollection;
		[objcCCollection release];
	}
	g_CollectionList.clear();
}
