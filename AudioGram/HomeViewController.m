//
//  HomeViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/2/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "HomeViewController.h"
#import "ImageCollectionViewCell.h"
#import <Parse/Parse.h>

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *homeCollectionView;
@property NSArray *photoArray;
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query selectKeys:@[@"objectId", @"createdAt",@"image"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        self.photoArray = objects;
        [self.homeCollectionView reloadData];

    }];


    
}

-(ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeImageCell" forIndexPath:indexPath];
    PFObject *object = [self.photoArray objectAtIndex:indexPath.row];
    PFFile *imageFile = [object objectForKey:@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        UIImage *image = [UIImage imageWithData:data];
        cell.imageView.image = image;
    }]; //prints out the image. must convert from file to data to image


    return cell;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoArray.count;
}



@end
