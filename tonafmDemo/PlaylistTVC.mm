//
//  PlaylistTVC.m
//  tonafmDemo
//
//  Created by Liangchuan Gu on 26/06/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import "PlaylistTVC.h"
#import "PlaylistTVCCell.h"
#import "Meter.h"

#import <AVFoundation/AVFoundation.h>


@interface PlaylistTVC ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) NSMutableArray *localMusicList;

@end

@implementation PlaylistTVC {
    BOOL _isPlaying;
    TONAFMLED::Meter meter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register music playr notifications
    _isPlaying = NO;
    [self configureAudioSession];
    CADisplayLink *dpLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [dpLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self loadAllMusic];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    MPMediaItem *item = (MPMediaItem *)[_localMusicList objectAtIndex:[indexPath row]];
    NSLog(@"Selected: %@", item.title);
    // get a URL reference to the selected item
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    // pass the URL to playURL:, defined earlier in this file
    [self playURL:url];
    //[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

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

#pragma mark - Music control

- (void)playPause {
    if (_isPlaying) {
        // Pause audio here
        [_audioPlayer pause];
    }
    else {
        // Play audio here
        [_audioPlayer play];
    }
    _isPlaying = !_isPlaying;
}

- (void)playURL:(NSURL *)url {
    if (_isPlaying) {
        [self playPause]; // Pause the previous audio player
    }
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [_audioPlayer setNumberOfLoops:-1];
    [_audioPlayer setMeteringEnabled:YES];
    [self playPause];   // Play
}

- (void)configureAudioSession {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
}

- (void)update
{
    // 1
    float scale = 0.5;
    if (_audioPlayer.playing )
    {
        // 2
        [_audioPlayer updateMeters];
        
        // 3
        float power = 0.0f;
        for (int i = 0; i < [_audioPlayer numberOfChannels]; i++) {
            power += [_audioPlayer averagePowerForChannel:i];
        }
        power /= [_audioPlayer numberOfChannels];
        
        // 4
        float level = meter.ValueAt(power);
        scale = level * 5;
        NSLog(@"Current scale: %f", scale);
    }
    
}

- (void)dealloc {
    // TODO
    
}

@end
