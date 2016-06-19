//
//  Artist.h
//  MemoryGame
//
//  
//  
//

@import UIKit;

@interface Artist : NSObject
@property (nonatomic, strong) NSString *artistId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSDictionary *artistInfo;
@property (nonatomic, strong) NSMutableArray *tracks;
@end
