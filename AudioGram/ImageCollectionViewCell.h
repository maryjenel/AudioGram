//
//  ImageCollectionViewCell.h
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/2/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@protocol ImageCollectionViewCellDelegate <NSObject>

- (void)didClickPlayButtonWithPhoto:(PFObject *)photo;
- (void)didClickLikeButtonWithPhoto:(PFObject *)photo;
- (void)didClickCommentButtonWithPhoto:(PFObject *)photo;

@end

@interface ImageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property PFObject *photo;

@property (weak, nonatomic) id <ImageCollectionViewCellDelegate> delegate;

@end
