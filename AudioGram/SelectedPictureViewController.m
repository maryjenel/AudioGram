//
//  SelectedPictureViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/3/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "SelectedPictureViewController.h"
#import <Parse/Parse.h>
#import "ProfileViewController.h"

@interface SelectedPictureViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *commentsArray;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLikes;

@end

@implementation SelectedPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFFile *imagefile = [self.photoObject objectForKey:@"image"];

    [imagefile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         UIImage *image = [UIImage imageWithData:data];
         self.imageView.image = image;
     //    self.photoIDString = imageString;
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getAllComments];
}

#pragma mark TableView Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFObject *comment = self.commentsArray[indexPath.row];
    cell.textLabel.text = comment[@"commentContext"];

    return cell;
}

#pragma mark Button Methods
- (IBAction)onCommentButtonPressed:(UIButton *)sender
{
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Add A Comment!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertcontroller addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        nil;
    }];

    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        UITextField *textField = alertcontroller.textFields.firstObject;
        PFObject *myComment = [PFObject objectWithClassName:@"Comment"];
        myComment[@"commentContext"] = textField.text;
        myComment[@"photo"] = self.photoObject;
        myComment[@"user"] = [PFUser currentUser];
        [myComment saveInBackground];
        [self getAllComments];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertcontroller addAction:okayAction];
    [alertcontroller addAction:cancelAction];

    [self presentViewController:alertcontroller animated:YES completion:^{
        nil;
    }];
}


- (IBAction)onLikeButtonPressed:(UIButton *)sender
{

}

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *addTagsAction = [UIAlertAction actionWithTitle:@"Add Tags" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"merp");

        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Add A Tag!" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertcontroller addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             nil;
         }];

        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            UITextField *textField = alertcontroller.textFields.firstObject;
            PFObject *tagsObject = [PFObject objectWithClassName:@"Tags"];
            tagsObject[@"content"] = textField.text;
            PFRelation *relation = [tagsObject relationForKey:@"photo"];
            [relation addObject:self.photoObject];
            [tagsObject saveInBackground];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertcontroller addAction:addAction];
        [alertcontroller addAction:cancelAction];

        [self presentViewController:alertcontroller animated:YES completion:^{
            nil;
        }];
    }];
    UIAlertAction *deletePhotoAction = [UIAlertAction actionWithTitle:@"Delete Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        [self.photoObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded && !error)
             {
                 NSLog(@"deleted from parse!");
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 NSLog(@"error: %@", error);
             }
         }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:cancelAction];
    [alertController addAction:addTagsAction];
    [alertController addAction:deletePhotoAction];
    [self presentViewController:alertController animated:YES completion:^{
        NSLog(@"yaaasss");
    }];


}


#pragma mark Helper Methods

- (void)getAllComments {
    //PULL OBJECT "PHOTO
    //SET A QUERY THOUGH THE OBJECT TO FIND THE COMMENT IT'S RELATED TO
    //LOAD IT ON TABLE VIEW

    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"photo" equalTo:self.photoObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.commentsArray = objects;
         [self.tableView reloadData];
     }];
}

@end
