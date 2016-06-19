//
//  ArtistDownloadOperation.h
//  MemoryGame
//
//  
//  
//

#import "ConcurrentOperation.h"

@interface ArtistDownloadOperation : ConcurrentOperation
@property (nonatomic, strong) NSString *artistId;
@end
