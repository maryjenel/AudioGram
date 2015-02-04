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

    // Check that the user has permission to record
    if([self.audioSession respondsToSelector:@selector(requestRecordPermission:)]){
        [self.audioSession requestRecordPermission:^(BOOL granted) {
            NSLog(@"Yeaaah!!!");
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
    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePicker animated:YES completion:nil];

}
- (IBAction)onShareButtonPressed:(UIButton *)sender
{
    // Save the image that was taken to the Photo Table in Parse
    NSData *imageData = UIImagePNGRepresentation(self.addPhotoImage); //changed the image to a png file
    PFFile *imageFile = [PFFile fileWithName:@"AudioGramPhoto.png" data:imageData]; //create a PFFile inorder to save to parse
     //absolutestring turns a NSURL into a string
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error) {
             NSLog(@"%@", imageFile);
             PFObject *photoObject = [PFObject objectWithClassName:@"Photo"];
             photoObject[@"photoURL"] = @"bart";
             photoObject[@"image"] = imageFile;
            [photoObject setObject:[PFUser currentUser] forKey:@"createdBy"];
             [photoObject saveInBackground];    // [Optional] Track statistics around application opens.
         }
     }];

    // Save the Audio that was recorded into the Audio Table in Parse
    NSData *audioData = [NSData dataWithContentsOfFile:[self.filePath path]]; // Create an data object with the recorded file path
    PFFile *audioFile = [PFFile fileWithName:@"recording.caf" data:audioData]; 
    [audioFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error) {
             PFObject *audioObject = [PFObject objectWithClassName:@"Audio"];
             audioObject[@"audioFile"] = audioFile;
             [audioObject saveInBackground];
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

- (IBAction)onStopButtonPressed:(UIButton *)sender
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

- (IBAction)onRecordButtonPressed:(UIButton *)sender
{
    // Check if the audio recorder is already recording
    if (!self.audioRecorder.recording) {
        // If not, start recording
        [self.audioRecorder record];
    }


}

@end
