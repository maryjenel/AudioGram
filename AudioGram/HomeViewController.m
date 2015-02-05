//
//  HomeViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/2/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "HomeViewController.h"
#import "ImageCollectionViewCell.h"
#import "MyLoginViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, PFSignUpViewControllerDelegate,PFLogInViewControllerDelegate, ImageCollectionViewCellDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *homeCollectionView;
@property NSArray *photoArray;
@property AVAudioPlayer *audioPlayer;

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![PFUser currentUser])
    {
        
        MyLoginViewController *loginViewController = [[MyLoginViewController alloc]init];
        [loginViewController setDelegate:self];

        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc]init];
        [signUpViewController setDelegate:self];

        [loginViewController setSignUpController:signUpViewController];

        [self presentViewController:loginViewController animated:YES completion:nil];
    }
}

-(BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0)
    {
        return YES;
    }
    [[[UIAlertView alloc]initWithTitle:@"Missing Information!" message:@"Make sure you fill out all the information, please!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    return NO;
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    for (id key in info)
    {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    if (!informationComplete)
    {
        [[[UIAlertView alloc]initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    }
    return informationComplete;
}

-(ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeImageCell" forIndexPath:indexPath];
    cell.delegate = self;
    PFObject *object = [self.photoArray objectAtIndex:indexPath.row];
    cell.photo = object;
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

#pragma mark PLAY, COMMENT AND LIKE
- (void)didClickPlayButtonWithPhoto:(PFObject *)photo
{
    NSLog(@"%@", photo);
    PFQuery *query = [PFQuery queryWithClassName:@"Audio"];
    [query whereKey:@"photo" equalTo:photo];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The Audio file could not be found, request failed.");
        } else {
            // The find succeeded.
//            NSLog(@"Successfully retrieved the Audio File.");
            PFFile *audioFile = object[@"audioFile"];

            [audioFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                NSError *playerError = nil;
                self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                if (playerError)
                {
                    NSLog(@"There was an error reading the audio file: %@", error);
                }
                else
                {
                    self.audioPlayer.delegate = self;
                    [self.audioPlayer prepareToPlay];
                    [self.audioPlayer setVolume:0.5];
                    self.audioPlayer.numberOfLoops = 1;
                    [self.audioPlayer play];
                }
            }];
        }
    }];
}



@end
