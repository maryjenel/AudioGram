//
//  ImageCollectionViewCell.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/2/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

- (IBAction)onPlayButtonPressed:(UIButton *)sender
{
    [self.delegate didClickPlayButtonWithPhoto:self.photo];
}

@end
