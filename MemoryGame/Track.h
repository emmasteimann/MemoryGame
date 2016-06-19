//
//  Track.h
//  MemoryGame
//
//  
//  
//

#import <Foundation/Foundation.h>
#import "Artist.h"

static int const pointsNeededToEarn = 3;

@interface Track : NSObject
@property (nonatomic, strong) NSString *trackId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *stream_url;
@property (nonatomic, strong) NSDictionary *trackInfo;
@property (nonatomic, assign) int pointsEarned;
@end
