//
//  SoundCloudClient.h
//  MemoryGame
//
//  
//  
//

#import <Foundation/Foundation.h>
#import "Artist.h"

@protocol ArtistDelegate
@optional
- (void)allArtistImagesLoaded;
- (void)artistTracksLoaded:(Artist *)artist;
@end

@interface SoundCloudClient : NSObject
@property (strong, nonatomic) NSMutableArray *artists;
@property (strong, nonatomic) NSDictionary *artistTrackImages;
@property (weak) id <ArtistDelegate> delegate;
@property (strong, nonatomic) NSArray *userIdArray;

+ (instancetype)sharedInstance;
- (NSArray *)loadArtistImages;
- (void)loadTrackImagesForArtist:(Artist *)artist;
@end
