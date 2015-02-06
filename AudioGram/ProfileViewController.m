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
#import "SelectedPictureViewController.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *photoArray;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property UIImagePickerController *imagePicker;
@property NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPostsLabel;


@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getAllPhotosByUser];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    PFObject *user = [PFUser currentUser];
    if (!(user[@"profilePhoto"] == nil))
    {

        PFFile *imagefile = [user objectForKey:@"profilePhoto"];
        [imagefile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             UIImage *image = [UIImage imageWithData:data];
             self.profileImageView.image = image;
         }];
    }

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
    [imagefile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         UIImage *image = [UIImage imageWithData:data];
         cell.imageView.image = image;
     }];
    NSInteger photoCount = self.photoArray.count;
    self.numberOfPostsLabel.text = [NSString stringWithFormat:@"%ld posts", (long)photoCount];
    return cell;
}


- (IBAction)onProfilePictureTapped:(UITapGestureRecognizer *)sender
{
  //  CGPoint touchPoint = [sender locationInView:self.view];
    [self.profileImageView addGestureRecognizer:sender];
    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePicker animated:YES completion:nil];

}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.profileImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData = UIImagePNGRepresentation(self.profileImageView.image);
    PFFile *imageFile = [PFFile fileWithName:@"ProfilePicture.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error) {
             PFObject *user = [PFUser currentUser];
             user[@"profilePhoto"] = imageFile;
             [user saveInBackground];
         }
     }];


}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SelectedPictureViewController *vc = segue.destinationViewController;
    UICollectionViewCell *cell = (UICollectionViewCell *)sender; // changes(casting) from ID to uicollectionviewcell
    self.selectedIndexPath = [self.collectionView indexPathForCell:cell];
    vc.photoObject = [self.photoArray objectAtIndex:self.selectedIndexPath.row];

}

@end
