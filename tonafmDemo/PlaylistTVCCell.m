//
//  PlaylistTVCCell.m
//  tonafmDemo
//
//  Created by Liangchuan Gu on 26/06/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import "PlaylistTVCCell.h"

@interface PlaylistTVCCell()


@end

@implementation PlaylistTVCCell

@synthesize songCover = _songCover;
@synthesize songTitle = _songTitle;

- (void) setup
{
    if (!_songCover) {
        _songCover = [UIImageView new];
    }
    if (!_songTitle) {
        _songTitle = [UILabel new];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
