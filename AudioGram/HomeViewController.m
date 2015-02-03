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
    }];

    
}

-(ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeImageCell" forIndexPath:indexPath];
    cell.imageView.image = [self.photoArray objectAtIndex:indexPath.row];

    return cell;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}



@end
