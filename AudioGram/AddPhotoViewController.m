//
//  AddPhotoViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/2/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "AddPhotoViewController.h"
#import <Parse/Parse.h>




@interface UIViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation AddPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}
- (IBAction)onCameraButtonPressed:(UIButton *)sender
{
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePicker animated:YES completion:nil];

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.imageView setImage:image];
    NSData *imageData = UIImagePNGRepresentation(image); //changed the image to a png file
    PFFile *imageFile = [PFFile fileWithName:@"AudioGramPhoto.png" data:imageData]; //create a PFFile inorder to save to parse
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error) {
             NSLog(@"%@", imageFile);
             PFObject *photoObject = [PFObject objectWithClassName:@"Photo"];
             photoObject[@"photoURL"] = @"bart";
             photoObject[@"image"] = imageFile;

             [photoObject saveInBackground];    // [Optional] Track statistics around application opens.
         }
     }];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
