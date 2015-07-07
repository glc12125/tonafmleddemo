//
//  PlaylistTVC.m
//  tonafmDemo
//
//  Created by Liangchuan Gu on 26/06/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import "PlaylistTVC.h"
#import "PlaylistTVCCell.h"

#import <MediaPlayer/MediaPlayer.h>
@import SystemConfiguration.CaptiveNetwork;

@interface PlaylistTVC ()

@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong) NSMutableArray *localMusicList;

@end

@implementation PlaylistTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize music player
    MPMusicPlayerController* appMusicPlayer =
    [MPMusicPlayerController applicationMusicPlayer];
    
    [appMusicPlayer setShuffleMode: MPMusicShuffleModeOff];
    [appMusicPlayer setRepeatMode: MPMusicRepeatModeNone];
    
    self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    // Register music plaer notifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleNowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:self.musicPlayer];
    [notificationCenter addObserver:self
                           selector:@selector(handlePlaybackStateChanged:)
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object:self.musicPlayer];
    [notificationCenter addObserver:self
                           selector:@selector(handleExternalVolumeChanged:)
                               name:MPMusicPlayerControllerVolumeDidChangeNotification
                             object:self.musicPlayer];
    [self.musicPlayer beginGeneratingPlaybackNotifications];
    
    [self loadAllMusic];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self fetchSSIDInfo];
}

- (void) loadAllMusic
{
    NSNumber *mediaTypeNumber = [NSNumber numberWithInteger:MPMediaTypeMusic];
    MPMediaPropertyPredicate *mediaTypePredicate =
    [MPMediaPropertyPredicate predicateWithValue: mediaTypeNumber
                                     forProperty: MPMediaItemPropertyMediaType];
    
    MPMediaQuery *allMusicQuery = [[MPMediaQuery alloc] init];
    [allMusicQuery addFilterPredicate: mediaTypePredicate];
    NSLog(@"Logging items from a generic query...");
    _localMusicList = [[NSMutableArray alloc] initWithArray:[allMusicQuery items]];
    for (MPMediaItem *song in _localMusicList) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog (@"%@", songTitle);
    }
    [_musicPlayer setQueueWithQuery: allMusicQuery];
}


#pragma mark Media player notification handlers
- (void) handleNowPlayingItemChanged: (id) notification
{}

- (void) handlePlaybackStateChanged: (id) notification
{}

- (void) handleExternalVolumeChanged: (id) notification
{}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_localMusicList count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"PlaylistTVCCell";
    
    PlaylistTVCCell *cell = (PlaylistTVCCell *)[tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PlaylistTVCCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (PlaylistTVCCell *)currentObject;
                break;
            }
        }
    }
    
    MPMediaItem *mediaItem = (MPMediaItem *)[_localMusicList objectAtIndex:[indexPath row]];
    
    cell.songTitle.text = [mediaItem title];
    MPMediaItemArtwork *itemArtwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *artworkImage = [itemArtwork imageWithSize: CGSizeMake(57, 57)];
    if (artworkImage) {
        cell.songCover.image = artworkImage;
    } else {
        cell.songCover.image = [UIImage imageNamed: @"noArtwork.png"];
    }

    return cell;
}

/** Returns first non-empty SSID network info dictionary.
 *  @see CNCopyCurrentNetworkInfo */
- (NSDictionary *)fetchSSIDInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
/*
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    MPMediaItem *anItem = (MPMediaItem *)[_localMusicList objectAtIndex:[indexPath row]];
    _musicPlayer.nowPlayingItem = anItem;
    [_musicPlayer play];
    NSLog(@"Selected: %@", anItem.title);
    //[tableView deselectRowAtIndexPath: indexPath animated: YES];
}*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:         _musicPlayer];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:         _musicPlayer];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerVolumeDidChangeNotification
     object:         _musicPlayer];
    
    [_musicPlayer endGeneratingPlaybackNotifications];
    
}

@end
