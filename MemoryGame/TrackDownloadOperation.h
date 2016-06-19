//
//  TrackDownloadOperation.h
//

#import "ConcurrentOperation.h"

@interface TrackDownloadOperation : ConcurrentOperation
@property (nonatomic, strong) NSString *artistId;
@end
