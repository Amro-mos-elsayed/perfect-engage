//
//  UUMessageContentButton.m
//  BloodSugarForDoc
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUMessageContentButton.h"

@implementation UUMessageContentButton


@synthesize message;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //图片
        audioDuration = _TotalDuration.integerValue;
        
        self.backImageView = [[UIImageView alloc]init];
        self.UserImageView = [[UIImageView alloc]init];
        self.RecordView = [[UIImageView alloc]init];
        self.Play_pause = [[UIImageView alloc]init];
        self.myProgressView = [[CustomSlider alloc]init];
        self.backImageView.userInteractionEnabled = YES;
        self.backImageView.layer.cornerRadius = 5;
        self.backImageView.layer.masksToBounds  = YES;
        self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backImageView.backgroundColor = [UIColor clearColor];
        self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.backImageView];
        self.voiceBackView = [[UIView alloc]init];
        [self addSubview:self.voiceBackView];
        //[self addSubview:self.myProgressView];
        self.second = [[UILabel alloc]init];
        self.second.font = [UIFont systemFontOfSize:12];
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicator.center=CGPointMake(80, 15);
        
        [self.voiceBackView addSubview:self.indicator];
        [self.voiceBackView addSubview:self.second];
        [self.voiceBackView addSubview:self.UserImageView];
        [self.voiceBackView addSubview:self.Play_pause];
        self.UserImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backImageView.userInteractionEnabled = NO;
        self.voiceBackView.userInteractionEnabled = NO;
        self.second.userInteractionEnabled = NO;
        self.second.backgroundColor = [UIColor clearColor];
        self.voiceBackView.backgroundColor = [UIColor clearColor];
        [self.voiceBackView addSubview:_UserImageView];
        [self.voiceBackView addSubview:_RecordView];
        [self.voiceBackView addSubview:self.myProgressView];
        
        [self addSubview:self.myProgressView];
        _Play_pause.image = [UIImage imageNamed:@"play"];
        _RecordView.image = [UIImage imageNamed:@"record_gray"];
        _downloadView.backgroundColor = [UIColor clearColor];
        
        self.myProgressView.minimumValue = 0.0f;
        self.myProgressView.maximumValue = 1.0f;
        
        [self.myProgressView setThumbImage:[UIImage imageNamed:@"minus1"] forState:UIControlStateNormal];
        
        self.myProgressView.userInteractionEnabled = YES;
        //self.myProgressView.clipsToBounds = YES;
        
        self.myProgressView.continuous = YES;
        
        self.myProgressView.minimumTrackTintColor = [UIColor clearColor];
        self.myProgressView.maximumTrackTintColor = [UIColor clearColor];
        
        [self SetDownloadProgress];
        [self addSubview:_downloadView];
        
        
    }
    
    return self;
}
-(void)SetDownloadProgress
{
    _downloadView = [[ACPDownloadView alloc] init];
    ACPIndeterminateGoogleLayer * layer = [ACPIndeterminateGoogleLayer new];
    [layer updateColor:[UIColor blueColor]];
    [self.downloadView setIndeterminateLayer:layer];
    _downloadView.backgroundColor = [UIColor clearColor];
    self.alpha = 1.0;
    // You can define a behaviour if the view is tapped. (Optional)
    __weak UUMessageContentButton *weak_self = self;
    [self.downloadView setActionForTap:^(ACPDownloadView *downloadView, ACPDownloadStatus status){
        switch (status)
        {
            case ACPDownloadStatusNone:
                [weak_self.delegate startDownload];
                [downloadView setIndicatorStatus:ACPDownloadStatusIndeterminate];
                break;
            case ACPDownloadStatusRunning:
                [downloadView setIndicatorStatus:ACPDownloadStatusCompleted];
                break;
            case ACPDownloadStatusIndeterminate:
                [downloadView setIndicatorStatus:ACPDownloadStatusRunning];
                break;
            case ACPDownloadStatusCompleted:
                [downloadView setIndicatorStatus:ACPDownloadStatusNone];
                break;
            default:
                break;
        }
    }];
    _downloadView.hidden = true;
    _downloadView.userInteractionEnabled = false;
}
-(void)SetProgress:(float )CurrentTime TotalTime:(float)TotalDuration
{
    //[_myProgressView setProgress:(CurrentTime / TotalDuration)];
}

-(void)SetFrame:(UUMessageFrame * )messageframe
{
    if (IS_IPHONE_5S)
    {
        [self.voiceBackView setFrame:CGRectMake(0, 0, self.frame.size.width, 90)];
    }
    else
    {
        [self.voiceBackView setFrame:CGRectMake(0, 0, self.frame.size.width, 90)];
    }
    _UserImageView.frame = CGRectMake(8, self.voiceBackView.center.y-30, 60, 60);
    _UserImageView.layer.cornerRadius  = _UserImageView.frame.size.width/2;
    _UserImageView.clipsToBounds = true;
    
    _Play_pause.frame = CGRectMake(_UserImageView.frame.origin.x+_UserImageView.frame.size.width+5, _UserImageView.frame.origin.y + 15, 25, 25);
    
    _RecordView.frame = CGRectMake(_UserImageView.frame.origin.x+_UserImageView.frame.size.width-15, _UserImageView.frame.origin.y + 35, 20, 20);
    
    _myProgressView.frame = CGRectMake(_Play_pause.frame.origin.x + 32, _Play_pause.frame.origin.y+10, self.voiceBackView.frame.size.width -_Play_pause.frame.origin.x - 35, 3);
    
    _myProgressView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    //_myProgressView.userInteractionEnabled = YES;
    _myProgressView.tintColor = [UIColor blueColor];
    [self.second setFrame:CGRectMake(_Play_pause.frame.origin.x+2, _Play_pause.frame.origin.y+_Play_pause.frame.size.height+4, 100, 20)];
    message  = messageframe.message;
    _downloadView.hidden = false;
    if(message.type == UUMessageTypeVoice)
    {
        _downloadView.frame = CGRectMake(_Play_pause.frame.origin.x, _Play_pause.frame.origin.y, _Play_pause.frame.size.width, _Play_pause.frame.size.height);
    }
    else if(message.type == UUMessageTypeVideo)
    {
        if(message.from == UUMessageFromMe)
        {
            _downloadView.hidden = true;
            
        }
        
        
        else
        {
            _downloadView.frame = CGRectMake(self.center.x-60/2, self.center.y-60/2, 60, 60);
            
        }
    }else if(message.type == UUMessageTypeContact){
        _UserImageView.frame = CGRectMake(8, self.voiceBackView.center.y-35, 45, 45);
        _UserImageView.layer.cornerRadius  = _UserImageView.frame.size.width/2;
        _UserImageView.clipsToBounds = true;
        [self.second setFrame:CGRectMake(self.UserImageView.frame.origin.x + self.UserImageView.frame.size.width + 5, self.voiceBackView.center.y-35, 120, 40)];
        self.second.font = [UIFont systemFontOfSize:16];
        _downloadView.hidden = true;
        _myProgressView.hidden = true;
        _RecordView.hidden = true;
        _Play_pause.hidden = true;
    }
    
    else
    {
        _downloadView.hidden = true;
    }
    NSLog(@"%@",message.conv_id);
}

-(void)StartLoading
{
    _downloadView.hidden = false;
    [_downloadView setIndicatorStatus:ACPDownloadStatusIndeterminate];
    
}

-(void)StartDownloading
{
    _downloadView.hidden = false;
    [_downloadView setIndicatorStatus:ACPDownloadStatusRunning];
    
}

-(void)RemoveLoading
{
    
    _downloadView.hidden = true;
    [_downloadView setIndicatorStatus:ACPDownloadStatusNone];
}

- (void)benginLoadVoice
{
    //[self.myProgressView setProgress:0 animated:NO];
    _Play_pause.image = [UIImage imageNamed:@"pause"];
    [self.indicator startAnimating];
    isAudioPlays = true;
}
- (void)didLoadVoice
{
    _Play_pause.image = [UIImage imageNamed:@"pause"];
    [self.indicator stopAnimating];
    isAudioPlays = false;
}
-(void)stopPlay
{
    _Play_pause.image = [UIImage imageNamed:@"play"];
    isAudioPlays = false;
}

-(void)StartPlay
{
    _Play_pause.image = [UIImage imageNamed:@"pause"];
    isAudioPlays = false;
}

- (void)setIsMyMessage:(BOOL)isMyMessage
{
    _isMyMessage = isMyMessage;
    if (isMyMessage) {
        self.backImageView.frame = CGRectMake(5, 5, 220, 220);
        self.second.textColor = [UIColor lightGrayColor];
    }else{
        self.backImageView.frame = CGRectMake(15, 5, 220, 220);
        self.second.textColor = [UIColor lightGrayColor];
    }
    if (isMyMessage==YES) {
        NSLog(@"to");
        //        self.voice.image = [UIImage imageNamed:@"mic"];
        //        self.voice.animationImages = [NSArray arrayWithObjects:
        //                                      [UIImage imageNamed:@"anim3"],
        //                                      [UIImage imageNamed:@"anim1"],
        //                                      [UIImage imageNamed:@"anim2"],nil];
        
    }
    else
    {
        NSLog(@"from");
        
        
    }
    
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}

-(void)copy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
}


@end
