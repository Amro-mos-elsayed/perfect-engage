//
//  UUMessageContentButton.h
//  BloodSugarForDoc
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 shake. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_5S (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#import <UIKit/UIKit.h>
#import <ACPDownload/ACPDownloadView.h>
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import <ACPDownload/ACPIndeterminateGoogleLayer.h>
#import <ACPDownload/ACPStaticImagesAlternative.h>
#import "CustomSlider.h"


@protocol UUMessageContentButtonDelegate <NSObject>

@optional
-(void)startDownload;
@end

@interface UUMessageContentButton : UIButton
{
    NSInteger audioDuration;
    
    BOOL   isAudioPlays;
 
}

//bubble image
@property (nonatomic, retain, nonnull) UIImageView *backImageView;

//audio
@property (nonatomic, retain, nonnull) UIView *voiceBackView;
@property (nonatomic, retain, nonnull) UILabel *second;
 @property (nonatomic, retain, nonnull) UIActivityIndicatorView *indicator;

@property (nonatomic, retain, nonnull) UIImageView *UserImageView;

@property (nonatomic, retain, nonnull) UIImageView *RecordView;

@property (nonatomic, retain, nonnull) UIImageView *Play_pause;

@property (atomic , strong, nonnull) NSString *TotalDuration;

@property (strong, nonatomic, nonnull) IBOutlet ACPDownloadView *downloadView;

-(void)SetProgress:(float )CurrentTime TotalTime:(float)TotalDuration;
@property (atomic , strong, nonnull) CustomSlider *myProgressView;

@property (weak, nonatomic, nullable) id<UUMessageContentButtonDelegate> delegate;

@property (nonatomic, strong, nonnull) UUMessage *message;

 
-(void)StartDownloading;

@property (nonatomic, assign) BOOL isMyMessage;

- (void)benginLoadVoice;

- (void)didLoadVoice;

-(void)StartPlay;

-(void)stopPlay;
-(void)StartLoading;
-(void)RemoveLoading;
-(void)SetFrame:(nonnull UUMessageFrame *)messageframe;
@end
