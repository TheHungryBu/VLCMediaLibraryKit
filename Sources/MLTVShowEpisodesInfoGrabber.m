/*****************************************************************************
 * MLTVShowEpisodesInfoGrabber.m
 * Lunettes
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2013 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#import "MLTVShowEpisodesInfoGrabber.h"
#import "TheTVDBGrabber.h"
#import "MLURLConnection.h"
#import "NSXMLNode_Additions.h"

@interface MLTVShowEpisodesInfoGrabber ()
#if !HAVE_BLOCK
    <MLURLConnectionDelegate>
#endif

@property (readwrite, retain) NSDictionary *results;
@property (readwrite, retain) NSArray *episodesResults;

- (void)didReceiveData:(NSData *)data;
@end

@implementation MLTVShowEpisodesInfoGrabber
@synthesize delegate=_delegate;
@synthesize episodesResults=_episodesResults;
@synthesize results=_results;
#if !HAVE_BLOCK
@synthesize userData=_userData;
#endif
- (void)dealloc
{
    [_connection release];
    [_results release];
    [_episodesResults release];
#if HAVE_BLOCK
    if (_block)
        Block_release(_block);
#else
    [_userData release];
#endif
    [super dealloc];
}

#if !HAVE_BLOCK
- (void)urlConnection:(MLURLConnection *)connection didFinishWithError:(NSError *)error
{
    if (error) {
        [_connection release];
        _connection = nil;
        [self autorelease];
        return;
    }
    [self didReceiveData:connection.data];
    [self autorelease];
}
#endif

- (void)lookUpForShowID:(NSString *)showId
{
    [_connection cancel];
    [_connection release];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:TVDB_QUERY_EPISODE_INFO, TVDB_HOSTNAME, TVDB_API_KEY, showId, TVDB_DEFAULT_LANGUAGE]];

    // Balanced below
    [self retain];

#if HAVE_BLOCK
    _connection = [[MLURLConnection runConnectionWithURL:url andBlock:^(MLURLConnection *connection, NSError * error) {
        if (error) {
            [_connection release];
            _connection = nil;
            [self autorelease];
            return;
        }
        [self didReceiveData:connection.data];
        [self autorelease];
    }] retain];
#else
    _connection = [[MLURLConnection runConnectionWithURL:url delegate:self userObject:nil] retain];
#endif
}

#if HAVE_BLOCK
- (void)lookUpForShowID:(NSString *)id andExecuteBlock:(void (^)())block
{
    Block_release(_block);
    _block = Block_copy(block);
    [self lookUpForShowID:id];
}
#endif

- (void)didReceiveData:(NSData *)data
{
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:nil];

    NSError *error = nil;
    NSArray *nodesSerie = [xmlDoc nodesForXPath:@"./Data/Series" error:&error];
    NSArray *nodesEpisode = [xmlDoc nodesForXPath:@"./Data/Episode" error:&error];


    NSString *serieArtworkURL = nil;
    if ([nodesSerie count] == 1) {
        NSXMLNode *node = [nodesSerie objectAtIndex:0];
        serieArtworkURL = [node stringValueForXPath:@"./poster"];
    }

    if ([nodesEpisode count] > 0 ) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[nodesEpisode count]];

        for (NSXMLNode *node in nodesEpisode) {
            NSString *episodeId = [node stringValueForXPath:@"./id"];
            if (!episodeId)
                continue;
            NSString *title = [node stringValueForXPath:@"./EpisodeName"];
            NSNumber *seasonNumber = [node numberValueForXPath:@"./SeasonNumber"];
            NSNumber *episodeNumber = [node numberValueForXPath:@"./EpisodeNumber"];
            NSString *artworkURL = [node stringValueForXPath:@"./filename"];
            NSString *shortSummary = [node stringValueForXPath:@"./Overview"];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              episodeId, @"id",
                              title ?: @"", @"title",
                              shortSummary ?: @"", @"shortSummary",
                              episodeNumber, @"episodeNumber",
                              seasonNumber, @"seasonNumber",
                              [NSString stringWithFormat:TVDB_COVERS_URL, TVDB_IMAGES_HOSTNAME, artworkURL], @"artworkURL",
                              nil]];
        }
        self.episodesResults = array;
        self.results = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:TVDB_COVERS_URL, TVDB_IMAGES_HOSTNAME, serieArtworkURL], @"serieArtworkURL", nil];
    }
    else {
        self.episodesResults = nil;
        self.results = nil;

    }

    [xmlDoc release];

#if HAVE_BLOCK
    if (_block) {
        _block();
        Block_release(_block);
        _block = NULL;
    }
#endif

    if ([_delegate respondsToSelector:@selector(movieInfoGrabberDidFinishGrabbing:)])
        [_delegate tvShowEpisodesInfoGrabberDidFinishGrabbing:self];
}

@end
