//
//  AddPhotoViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/2/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "AddPhotoViewController.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>

@interface AddPhotoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate,AVAudioRecorderDelegate>

@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property AVAudioRecorder *audioRecorder;
@property AVAudioPlayer *audioPlayer;
@property AVAudioSession *audioSession;


@property NSURL *documents;
@property NSURL *filePath;
@property UIImage *addPhotoImage;

@property PFObject *currentPhoto;
@property (weak, nonatomic) IBOutlet UIButton *addTagButton;

@end

@implementation AddPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.audioSession = [AVAudioSession sharedInstance];

    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.audioPlayer.delegate = self;
    self.audioRecorder.delegate = self;

    if (!self.currentPhoto) {
        self.addTagButton.enabled = NO;
    }

    // Check that the user has permission to record
    if([self.audioSession respondsToSelector:@selector(requestRecordPermission:)]){
        [self.audioSession requestRecordPermission:^(BOOL granted) {
            if (!granted)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Required" message:@"This app requires you to allow microphone use" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }

    // Create a url for where to store the recording
    self.documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    self.filePath = [self.documents URLByAppendingPathComponent:@"recording.caf"];

    NSDictionary *recorderSettings = @{
                                       AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
                                       AVSampleRateKey: [NSNumber numberWithFloat:44100.0],
                                       AVNumberOfChannelsKey: [NSNumber numberWithInt: 2],
                                       AVLinearPCMBitDepthKey: [NSNumber numberWithInt:16],
                                       AVLinearPCMIsBigEndianKey:[NSNumber numberWithBool:NO],
                                       AVLinearPCMIsFloatKey:[NSNumber numberWithBool:NO]
                                       };

    // Handle the error when creating a new instance of the audio recorder
    NSError *error = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.filePath settings:recorderSettings error:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    else
    {
        [self.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [self.audioRecorder prepareToRecord];
    }
}

- (IBAction)onCameraButtonPressed:(UIButton *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *chooseFromPhotos = [UIAlertAction actionWithTitle:@"Choose From Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:takePhotoAction];
    [alertController addAction:chooseFromPhotos];
    [self presentViewController:alertController animated:YES completion:^{

    }];
}

- (IBAction)onShareButtonPressed:(UIButton *)sender
{
    [self stopRecordingAndPlaying];

    // enable the tag
    self.addTagButton.enabled = YES;

    // Save the image that was taken to the Photo Table in Parse
    NSData *imageData = UIImagePNGRepresentation(self.addPhotoImage); //changed the image to a png file
    PFFile *imageFile = [PFFile fileWithName:@"AudioGramPhoto.png" data:imageData]; //create a PFFile inorder to save to parse
     //absolutestring turns a NSURL into a string
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         // Once the image has been saved create a new pf object and store the values for that photo
         if (!error) {
             NSLog(@"%@", imageFile);
             PFObject *photoObject = [PFObject objectWithClassName:@"Photo"];
             photoObject[@"image"] = imageFile;
             [photoObject setObject:[PFUser currentUser] forKey:@"createdBy"];
             [photoObject saveInBackground];// [Optional] Track statistics around application opens.

             // Save the Audio that was recorded into the Audio Table in Parse
             NSData *audioData = [NSData dataWithContentsOfFile:[self.filePath path]]; // Create an data object with the recorded file path
             PFFile *audioFile = [PFFile fileWithName:@"recording.caf" data:audioData];
             [audioFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  // Create an audio object and save it in parse
                  if (!error) {
                      PFObject *audioObject = [PFObject objectWithClassName:@"Audio"];
                      audioObject[@"audioFile"] = audioFile;
                      audioObject[@"user"] = [PFUser currentUser];
                      audioObject[@"photo"] = photoObject;
                      [audioObject saveInBackground];

                      // Once the image has been saved along with the video save it to
                      // currentPhoto property
                      self.currentPhoto = photoObject;
                  }
              }];
         }
     }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.imageView.image = image;
    self.addPhotoImage = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPlayButtonPressed:(UIButton *)sender
{
    //    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    if (self.audioRecorder.recording) {
    //        [self.audioRecorder stop];
    //    }
    // Setup the audio player
    NSURL *filePathMusic = [self.documents URLByAppendingPathComponent:@"recording.caf"];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePathMusic error:&error];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer setVolume:0.5];
    self.audioPlayer.numberOfLoops = 1;
    [self.audioPlayer play];
}

- (void)stopRecordingAndPlaying
{
    // Check if the audio recorder is already recording
    if (self.audioRecorder.recording) {
        // If it is, stop recording
        [self.audioRecorder stop];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
    }
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
    }
}

- (IBAction)onStopButtonPressed:(UIButton *)sender
{
    [self stopRecordingAndPlaying];
}

- (IBAction)onRecordButtonPressed:(UIButton *)sender
{
    // Check if the audio recorder is already recording
    if (!self.audioRecorder.recording) {
        // If not, start recording
        [self.audioRecorder record];
    }
}

- (IBAction)addTagsButtonTapped:(UIButton *)sender
{
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
        [relation addObject:self.currentPhoto];
        [tagsObject saveInBackground];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertcontroller addAction:addAction];
    [alertcontroller addAction:cancelAction];

    if (self.currentPhoto) {
        [self presentViewController:alertcontroller animated:YES completion:^{
            nil;
        }];
    }
    else
    {

    }
}

@end
