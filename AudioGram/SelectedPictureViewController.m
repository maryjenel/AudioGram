//
//  SelectedPictureViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/3/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "SelectedPictureViewController.h"
#import <Parse/Parse.h>

@interface SelectedPictureViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *commentsArray;

@end

@implementation SelectedPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];


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
//    PFObject *currentComment = [PFObject objectWithClassName:@"Comment"];//photo
//    cell.textLabel.text = currentComment[@"commentContext"];
    //[currentComment saveInBackground];
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
        //[myComment setObject:[PFObject objectWithClassName:@"Photo"] forKey:<#(NSString *)#>]
        myComment[@"commentContext"] = textField.text;
        [myComment saveInBackground];

    }];

    [alertcontroller addAction:okayAction];

    [self presentViewController:alertcontroller animated:YES completion:^{
        nil;
    }];
}


// WILL ADD LATER
- (IBAction)onLikeButtonPressed:(UIButton *)sender
{

}

#pragma mark Helper Methods

- (void)getAllComments {
    //PULL OBJECT "PHOTO
    //SET A QUERY THOUGH THE OBJECT TO FIND THE COMMENT IT'S RELATED TO
    //LOAD IT ON TABLE VIEW

    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.commentsArray = objects;
         [self.tableView reloadData];
     }];
}

@end
