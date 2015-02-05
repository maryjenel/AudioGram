//
//  ProfileViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/3/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "ProfileViewController.h"
#import "ImageCollectionViewCell.h"
#import <Parse/Parse.h>

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *photoArray;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getAllPhotosByUser];
}

- (void)getAllPhotosByUser
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.photoArray = [objects mutableCopy];
        [self.collectionView reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self getAllPhotosByUser];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCell" forIndexPath:indexPath];
    PFObject *object = [self.photoArray objectAtIndex:indexPath.row];
    PFFile *imagefile = [object objectForKey:@"image"];
    [imagefile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        cell.imageView.image = image;
    }];
    return cell;
}

@end
