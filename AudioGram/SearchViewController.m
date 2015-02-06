//
//  SearchViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/3/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "SearchViewController.h"
#import "ImageCollectionViewCell.h"

@interface SearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *photoArray;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.photoArray = [NSMutableArray new];
}


#pragma mark Collection View Methods
//TABLE VIEW METHODS
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCell" forIndexPath:indexPath];

    PFObject *photoObject = self.photoArray[indexPath.row];
    PFFile *file = photoObject[@"image"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        cell.imageView.image = image;
    }];
    return cell;
}

#pragma mark Helper Methods
//HELPER METHODS
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.photoArray removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tags"];
    [query whereKey:@"content" containsString:searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
        NSArray *tagObjects = objects;
         for (PFObject *tag in tagObjects)
         {
            PFRelation *relation = [tag relationForKey:@"photo"];
            PFQuery *query = [relation query];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                for (PFObject *photoObject in objects) {
                    [self.photoArray addObject:photoObject];
                }
                [self.collectionView reloadData];
          }];
        }
     }];
    [searchBar resignFirstResponder];
}

@end
