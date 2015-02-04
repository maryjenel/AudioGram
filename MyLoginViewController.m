//
//  MyLoginViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/3/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "MyLoginViewController.h"
#import "FLAnimatedImage.h"




@interface MyLoginViewController ()


@end

@implementation MyLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.logInView.dismissButton setHidden:YES];

    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"musicVideotest2" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 40, 375, 190)];
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webView.scalesPageToFit = YES;
    [self.logInView setBackgroundColor:[UIColor blackColor]];

  //  UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 350, 250)];

    [self.view addSubview:webView];

    //    NSURL *url = [[NSBundle mainBundle] URLForResource:@"musicVideotest2" withExtension:@"gif"];
//    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
//
//    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc]init];
//    imageView.animatedImage = image;
//    self.logInView.backgroundColor = [UIColor colorWithPatternImage:imageView.image];
//

//    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithData:gif]]];
  //  UIGraphicsBeginImageContext(self.view.frame.size);
//    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 247)];
//    imgView.image = [UIImage imageNamed:@"headphones"];
//    UIImage *img = [UIImage imageNamed:@"headphone"];
//    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:img]];

    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AudioGram"]]];
}

@end
