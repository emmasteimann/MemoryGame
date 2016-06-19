//
//  GameScene.m
//  MemoryGame
//
//  
//  
//

#import "GameScene.h"
#import "GridNode.h"
#import "ArtistNode.h"
#import "MyUtils.h"
#import "SoundCloudClient.h"
#import "Artist.h"
#import "GameManager.h"
#import "AlbumSquareNode.h"
#import "Track.h"
#import "ImageDownloader.h"
#import "TrackWonSquare.h"
#import "Constants.h"
#import "EarnedHeartsNode.h"
#import "DefaultLabelNode.h"
@import AVFoundation;

@interface GameScene()
@property (assign, nonatomic) int currentGridSize;
@property (nonatomic, strong) ImageDownloader *imageDownloader;
@property (strong, nonatomic) AVPlayer *player;
@end

@implementation GameScene {
  int _currentRound;
  int _currentTimerCountDown;
  GridNode *_gameGrid;
  SKNode *_artistSelectNode;
  SKNode *_gamePlayNode;
  SKNode *_musicNode;
  ArtistNode *_noticeDrawer;
  SKSpriteNode *_homeButton;
  SKSpriteNode *_musicButton;
  EarnedHeartsNode *_earnedNode;
  Artist *_currentlySelectedArtist;
  Track *_currentlyLoadedTrack;
  CGFloat _sceneHeight;
  CGFloat _sceneWidth;
  NSUserDefaults *_defaults;
  NSTimer *_currentTimer;
}

-(instancetype)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.imageDownloader = [[ImageDownloader alloc] init];
    _currentRound = 2;
    _currentGridSize = [GameManager sharedInstance].gridSize;
    _currentTimerCountDown = 0;
    _currentlySelectedArtist = nil;
    _artistSelectNode = [SKNode node];
    _gamePlayNode = [SKNode node];
    _musicNode = [SKNode node];
    _defaults = [NSUserDefaults standardUserDefaults];
  }
  return self;
}

-(void)didMoveToView:(SKView *)view {
  _sceneWidth = self.size.width;
  _sceneHeight = self.size.height;
  [self addChild:_artistSelectNode];
  
  _homeButton = [SKSpriteNode spriteNodeWithImageNamed:@"house"];
  _homeButton.size = CGSizeMake(50, 50);
  _homeButton.name = @"home-button";
  _homeButton.position = CGPointMake(50, 50);
  _homeButton.hidden = YES;
  [self addChild:_homeButton];
  
  _musicButton = [SKSpriteNode spriteNodeWithImageNamed:@"notes"];
  _musicButton.size = CGSizeMake(40, 40);
  _musicButton.position = CGPointMake(_sceneWidth - ((_sceneWidth/20) * 2), _sceneHeight -(_sceneHeight/20));
  _musicButton.name = @"music-button";
  [self addChild:_musicButton];
  
  [self addChild:_musicNode];
  _musicNode.hidden = YES;
  [self addChild:_gamePlayNode];
  
  [GameManager sharedInstance];
  [[SoundCloudClient sharedInstance] setDelegate:self];
  if ([GameManager sharedInstance].gameState < 1) {
    [[SoundCloudClient sharedInstance] loadArtistImages];
  }
  
  [_defaults setBool:YES forKey:@"FirstTimeLoaded"];
  [_defaults synchronize];
  
}

#pragma mark - Builder Methods

-(void)buildAlbumDrawer {
  _noticeDrawer = [[ArtistNode alloc] initWithColor:[UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:0.5] size:CGSizeMake(self.view.bounds.size.width, 60)];
  _noticeDrawer.alpha = 0;
  _noticeDrawer.position = CGPointMake(self.size.width/2, _sceneHeight-(_sceneHeight/20 * 3));
  [_gamePlayNode addChild:_noticeDrawer];
  [_noticeDrawer runAction:[SKAction fadeAlphaTo:1 duration:1] withKey:@"add-drawer"];
}

-(void)buildGameGrid {
  // Build the game grid for track and current level of fun! ;-)
  int gridSize = _currentGridSize * 2;
  
  int x = gridSize / 2;
  int y = gridSize / 2;
  
  float desiredMeasurement = self.view.bounds.size.width - 40;
  
  _gameGrid = [[GridNode alloc] initWithWidth:desiredMeasurement andX:x andY:y];
  [_gameGrid setDelegate:self];
  _gameGrid.position = CGPointMake(self.size.width/2, _sceneHeight - (_gameGrid.size.height/2) - (_sceneHeight/20 * 5));
  
  _gameGrid.alpha = 0;
  
  addtoNodeWithRoundedCorners(_gamePlayNode, _gameGrid);
  
  int artistLevel = [[GameManager sharedInstance] getArtistComplication:_currentlySelectedArtist];
  
  SKAction *loadSquares = [SKAction runBlock:^{
    [_gameGrid loadSquares:artistLevel withImage:_currentlyLoadedTrack.image];
  }];
  
  [_gameGrid runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:0.5], loadSquares]]];
}

#pragma mark - Grid Delegate Methods

- (void)gridFullyLoaded {
  [GameManager sharedInstance].waitingForTrackDownloadToFinish = NO;
  [self loadTimer];
}

#pragma mark - Timer Methods

- (void)loadTimer {
  // Setup initial timer for current track grid game
  _currentTimerCountDown = 5;
  SKLabelNode *label = (SKLabelNode *)[_gamePlayNode childNodeWithName:@"note-label"];
  if (!label) {
    label = [DefaultLabelNode labelNodeWithText:@"Remember the placement!"];
    label.name = @"note-label";
    label.position = CGPointMake(self.size.width/2, (_sceneHeight/20 * 3));
    [_gamePlayNode addChild:label];
    
    DefaultLabelNode *timer = [DefaultLabelNode labelNodeWithText:[NSString stringWithFormat:@"%d", _currentTimerCountDown]];
    timer.name = @"current-timer";
    timer.fontSize = 30.0f;
    timer.position = CGPointMake(self.size.width/2, (_sceneHeight/20 * 2));
    [_gamePlayNode addChild:timer];
    
  } else {
    SKLabelNode *timer = (SKLabelNode *)[_gamePlayNode childNodeWithName:@"current-timer"];
    label.text = @"Remember the placement!";
    timer.text = [NSString stringWithFormat:@"%d", _currentTimerCountDown];
    timer.hidden = NO;
  }
  
  _currentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                   target:self selector:@selector(trigger:) userInfo:nil repeats:YES];
}

- (void)trigger:(NSTimer *)sender{
  // Start the count down for the game
  if (_currentTimerCountDown == 0){
    // Hide the nodes, the user's ready to play!
    [sender invalidate];
    [_gameGrid hideAndWaitGuess];
    [_gamePlayNode childNodeWithName:@"current-timer"].hidden = YES;
    SKLabelNode *label = (SKLabelNode *)[_gamePlayNode childNodeWithName:@"note-label"];
    label.text = @"Guess!";
    [GameManager sharedInstance].gameState = WaitingForGuess;
  } else {
    _currentTimerCountDown -= 1;
    SKLabelNode *label = (SKLabelNode *)[_gamePlayNode childNodeWithName:@"current-timer"];
    label.text = [NSString stringWithFormat:@"%d", _currentTimerCountDown];
  }
}

#pragma mark - SoundCloudClient Delegate Methods

- (void)artistTracksLoaded:(Artist *)artist {
  NSArray *tracks = artist.tracks;
  
  if ([tracks count] == 0) {
    return;
  }
  
  Track *track = (Track *)tracks[0];
  
  _currentlyLoadedTrack = track;
  
  
  // Build track tray
  DefaultLabelNode *artistLabel = [DefaultLabelNode labelNodeWithText:artist.name];
  artistLabel.name = @"name-label";
  artistLabel.position = CGPointMake(self.size.width/2, _sceneHeight-(_sceneHeight/20)-10);
  [_gamePlayNode addChild:artistLabel];
  
  DefaultLabelNode *noticeLabel = [DefaultLabelNode labelNodeWithText:@"Earning Song:"];
  noticeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  noticeLabel.name = @"earning-label";
  noticeLabel.fontSize = 12.0f;
  noticeLabel.position = CGPointMake(-_sceneWidth/2+_sceneWidth/20,_noticeDrawer.size.height/2-20);
  [_noticeDrawer addChild:noticeLabel];

  DefaultLabelNode *trackLabel = [DefaultLabelNode labelNodeWithText:track.title];
  trackLabel.name = @"track-label";
  trackLabel.position = CGPointMake(0,-10);
  
  [self adjustLabelFontSizeToFitRect:trackLabel rect:CGSizeMake(200, 100)];
  [_noticeDrawer addChild:trackLabel];
  
  SKSpriteNode *trackArtwork = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:_currentlyLoadedTrack.image] size:CGSizeMake(50, 50)];
  trackArtwork.alpha = 1.0f;
  trackArtwork.position = CGPointMake(_sceneWidth/2-(_sceneWidth/20*2), 0);
  [_noticeDrawer addChild:trackArtwork];
  
  
  // Build Grid
  [self buildGameGrid];
  
  
  // Load hearts for track
  _earnedNode = [[EarnedHeartsNode alloc] init];
  _earnedNode.position = CGPointMake(_sceneWidth/2, _sceneHeight/2 - _gameGrid.size.height/2 - 30);
  [_gamePlayNode addChild:_earnedNode];
  
  _homeButton.hidden = NO;
}

- (void)allArtistImagesLoaded {
  [GameManager sharedInstance].gameState = ImagesReady;
  [self displayArtists];
}

- (void)displayArtists {
  NSArray *artists = [SoundCloudClient sharedInstance].artists;
  CGFloat desiredRowHeight = self.view.bounds.size.height/9;
  
  // Build orange top header
  
  SKSpriteNode *newAlbumDrawer = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:1.00 green:0.47 blue:0.00 alpha:1.0] size:CGSizeMake(self.view.bounds.size.width, desiredRowHeight)];
  newAlbumDrawer.position = CGPointMake(self.size.width/2, self.size.height - desiredRowHeight/2);
  [_artistSelectNode addChild:newAlbumDrawer];
  
  DefaultLabelNode *label = [DefaultLabelNode labelNodeWithText:@"Choose an artist"];
  label.name = @"intro-label";
  label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  label.fontSize = 15.0f;
  label.position = CGPointMake(-newAlbumDrawer.size.width/2 + 110, 5);
  
  [newAlbumDrawer addChild:label];
  
  DefaultLabelNode *labelPt2 = [DefaultLabelNode labelNodeWithText:@"and earn songs!"];
  labelPt2.name = @"intro-label";
  labelPt2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  labelPt2.fontSize = 15.0f;
  labelPt2.position = CGPointMake(-newAlbumDrawer.size.width/2 + 110, -15
                                  );
  [newAlbumDrawer addChild:labelPt2];
  
  SKSpriteNode *sc = [SKSpriteNode spriteNodeWithImageNamed:@"soundcloud"];
  sc.position = CGPointMake(-self.size.width/2 + 60, 0);
  sc.size = CGSizeMake(60, 60);
  [newAlbumDrawer addChild:sc];
  
  int number = 0;
  int rowMultiplier = 1;
  NSArray *colorArray = @[[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0], [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
  
  
  // Build artist select table
  for (Artist *artist in artists) {
    int spotInArray = number % 2;
    ArtistNode *newAlbumDrawer = [[ArtistNode alloc] initWithColor:colorArray[spotInArray] size:CGSizeMake(self.view.bounds.size.width, desiredRowHeight)];
    
    newAlbumDrawer.position = CGPointMake(self.size.width/2, self.size.height - desiredRowHeight/2 - ((desiredRowHeight) * rowMultiplier));
    newAlbumDrawer.name = @"artists-unselected";
    newAlbumDrawer.artist = artist;
    
    [_artistSelectNode addChild:newAlbumDrawer];
    
    SKTexture *avatarTexture = [SKTexture textureWithImage:artist.avatar];
    ArtistNode *avatarNode = [ArtistNode spriteNodeWithTexture:avatarTexture];
    avatarNode.size = CGSizeMake(60, 60);
    avatarNode.name = @"avatar-node";
    avatarNode.position = CGPointMake(-newAlbumDrawer.size.width/2 + 60, 0);
    [newAlbumDrawer addChild:avatarNode];
    
    DefaultLabelNode *label = [DefaultLabelNode labelNodeWithText:artist.name];
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    label.name = @"artist-label";
    label.fontSize = 15.0f;
    label.userInteractionEnabled = NO;
    label.position = CGPointMake(-newAlbumDrawer.size.width/2 + (60 * 2), -5);
    [newAlbumDrawer addChild:label];
    
    number += 1;
    rowMultiplier += 1;
  }
}


#pragma mark - Touch Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
      CGPoint location = [touch locationInNode:self];
      
      __block SKNode *node = [self nodeAtPoint:location];
      
      if ([node.name isEqualToString:@"stream-button"] || [node.name isEqualToString:@"play-button"]) {
        if ([node.name isEqualToString:@"play-button"]) {
          node = node.parent;
        }
        
        // Stop all previous streams
        [self.player pause];
        [_musicNode enumerateChildNodesWithName:@"stream-button" usingBlock:^(SKNode * _Nonnull playNode, BOOL * _Nonnull stop) {
          SKSpriteNode *playButton = (SKSpriteNode *)[playNode childNodeWithName:@"play-button"];
          playButton.texture = [SKTexture textureWithImageNamed:@"play-button"];
        }];
        
        TrackWonSquare *streamNode = (TrackWonSquare *)node;
        
        if (streamNode.isStreaming) {
          streamNode.isStreaming = NO;
        } else {
          
          // Stream track
          NSString *streaming = [NSString stringWithFormat:@"%@?client_id=%@", streamNode.streamUrl, clientID];
          AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:streaming]];
          self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
          [self.player play];
          SKSpriteNode *playButton = (SKSpriteNode *)[streamNode childNodeWithName:@"play-button"];
          playButton.texture = [SKTexture textureWithImageNamed:@"pause-button"];
          streamNode.isStreaming = YES;
        }
      }
      
      if ([node.name isEqualToString:@"music-button"]) {
        // Build Music play screen
        _musicNode.hidden = NO;
        _gamePlayNode.hidden = YES;
        _homeButton.hidden = NO;
        _musicButton.hidden = YES;
        _artistSelectNode.hidden = YES;
        
        NSMutableDictionary *tracksWon = [_defaults objectForKey:@"tracks-won"];
        
        int number = 0;
        for (NSString *key in tracksWon) {
          NSString *imageUrl = [[tracksWon objectForKey:key] objectForKey:@"image_url"];
          __block NSString *streamUrl = [[tracksWon objectForKey:key] objectForKey:@"stream_url"];
          __block CGFloat trackImageSize = _sceneWidth/6;
          
          [self.imageDownloader loadImageFromURLString:imageUrl callback:^(UIImage *image, NSString *url){
            
              // Do this on the main queue as we're updating visuals
              dispatch_async(dispatch_get_main_queue(), ^{
                // Setup won track images
                TrackWonSquare *trackImage = [TrackWonSquare spriteNodeWithTexture:[SKTexture textureWithImage:image]];
                trackImage.size = CGSizeMake(trackImageSize, trackImageSize);
                trackImage.name = @"stream-button";
                trackImage.streamUrl = streamUrl;
                
                // Cycle through nodes and place
                int rowNumber = floor(number / 6) + 1;
                int columnNumber = number % 6 ;

                trackImage.position = CGPointMake((columnNumber * trackImageSize)+trackImageSize/2, _sceneHeight - (trackImageSize * rowNumber) + trackImageSize/2);
                trackImage.zPosition = -1;
                
                // Add play/pause button
                SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"play-button"];
                playButton.size = CGSizeMake(50, 50);
                playButton.position = CGPointMake(0, 0);
                playButton.name = @"play-button";
                playButton.alpha = 0.75f;
                playButton.zPosition = 99;
                [trackImage addChild:playButton];
                [_musicNode addChild:trackImage];
              });
          }];
          
          number += 1;
        }
        return;
      }
      
      if ([node.name isEqualToString:@"home-button"] && ![GameManager sharedInstance].waitingForTrackDownloadToFinish) {
        
        // Hide all unneccesary items
        [self.player pause];
        [_musicNode removeFromParent];
        _musicNode = [SKNode node];
        [self addChild:_musicNode];
        
        // Reset user and track
        if (_currentlySelectedArtist) {
          [[GameManager sharedInstance] resetArtistLevel:_currentlySelectedArtist andTrack:_currentlyLoadedTrack];
        }
        
        [_gamePlayNode removeFromParent];
        _gamePlayNode = [SKNode node];
        [self addChild:_gamePlayNode];
        
        _artistSelectNode.hidden = NO;
        _homeButton.hidden = YES;
        _musicButton.hidden = NO;
        _musicNode.hidden = YES;
        [GameManager sharedInstance].gameState = ImagesReady;
        [_currentTimer invalidate];
        return;
      }
      
      if ([GameManager sharedInstance].gameState == WaitingForGuess) {
        
        // Check to see if clicked item is an track/album node
        SKLabelNode *label = (SKLabelNode *)[_gamePlayNode childNodeWithName:@"note-label"];
        if ([node respondsToSelector:@selector(isAnActiveNode)]) {
          
          AlbumSquareNode *albumNode = (AlbumSquareNode *)node;
          
          // If active bump the counter
          if (albumNode.isAnActiveNode) {
            _gameGrid.activatedNodeCounter += 1;
            label.text = @"YAY!";
            albumNode.alpha = 1;
            albumNode.texture = [SKTexture textureWithImage:_currentlyLoadedTrack.image];
            if (_gameGrid.activatedNodeCounter == [_gameGrid.activeNodes count]) {
              label.text = @"You win this round!";
              [[GameManager sharedInstance] increaseArtistComplication:_currentlySelectedArtist];
              
              NSNumber *trackCounter = [_defaults objectForKey:[NSString stringWithFormat:@"%@", _currentlyLoadedTrack.trackId]];
              
              if (trackCounter == nil) {
                trackCounter = [NSNumber numberWithInt:1];
              } else {
                trackCounter = [NSNumber numberWithInt:([trackCounter intValue] + 1)];
              }
              
              [_defaults setObject:trackCounter forKey:[NSString stringWithFormat:@"%@", _currentlyLoadedTrack.trackId]];
              [_defaults synchronize];
              
              
              [_earnedNode setActiveHeart:[trackCounter intValue]];
              
              [GameManager sharedInstance].gameState = ImagesReady;
              [_gameGrid removeFromParent];
              
              if ([trackCounter intValue] == 3) {
                [[GameManager sharedInstance] addToTracksWon:_currentlyLoadedTrack withArtist:_currentlySelectedArtist];
                
                [_noticeDrawer removeAllActions];
                [_noticeDrawer removeFromParent];
                
                [self buildAlbumDrawer];
                
                [_earnedNode resetHeartCounter];

                [self artistTracksLoaded:_currentlySelectedArtist];
              } else {
                [self buildGameGrid];
              }
            }
            
          } else {
            // If isn't active reset the game
            [[GameManager sharedInstance] resetArtistLevel:_currentlySelectedArtist andTrack:_currentlyLoadedTrack];
            [_earnedNode resetHeartCounter];
            
            [GameManager sharedInstance].gameState = ImagesReady;
            label.text = @"Restarting!";
            
            [_gameGrid removeFromParent];
            
            [self buildGameGrid];
            return;
          }
        }
      }
      
      if ([node.name isEqualToString:@"artist-label"] || [node.name isEqualToString:@"avatar-node"]) {
        node = node.parent;
      }
      
      if ([node.name isEqualToString:@"artists-unselected"] && [GameManager sharedInstance].gameState == ImagesReady) {
        
        // Setup game for selected artist
        ArtistNode *avatar = (ArtistNode *)[node childNodeWithName:@"avatar-node"];
        
        CGPoint newPosition = [node convertPoint:avatar.position toNode:self];
        ArtistNode *copiedNode = [[node childNodeWithName:@"avatar-node"] copy];
        copiedNode.position = newPosition;
        
        [_gamePlayNode addChild:copiedNode];
        
        [self buildAlbumDrawer];
        _currentlySelectedArtist = [(ArtistNode *)node artist];
        
        // Fancy avatar slide animation
        SKAction *moveToFirstPosition = [SKAction moveTo:CGPointMake((_sceneWidth/20) *2, _sceneHeight-((_sceneHeight/20))) duration:0.5];
        __block SKAction *shrink = [SKAction scaleTo:0.75 duration:0.5];
        [copiedNode runAction:moveToFirstPosition];
        [copiedNode runAction:shrink];
        _artistSelectNode.hidden = YES;
        [GameManager sharedInstance].gameState = HasSelectedFirstArtist;
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *buildGrid = [SKAction runBlock:^{
          // Load track images for artist
          [GameManager sharedInstance].waitingForTrackDownloadToFinish = YES;
          [[SoundCloudClient sharedInstance] loadTrackImagesForArtist:_currentlySelectedArtist];
        }];
        
        [self runAction:[SKAction sequence:@[wait, buildGrid]]];
        return;
      }
    }

}

#pragma mark - Utility Methods

-(void)adjustLabelFontSizeToFitRect:(SKLabelNode*)labelNode rect:(CGSize)rect {
  double scalingFactor = MIN(rect.width / labelNode.frame.size.width, rect.height / labelNode.frame.size.height);
  labelNode.fontSize *= scalingFactor;
}

@end
