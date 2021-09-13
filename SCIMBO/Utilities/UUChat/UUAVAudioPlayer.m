//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUAVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UUAVAudioPlayer ()<AVAudioPlayerDelegate>
{
    NSTimer *countDownTimer;
    Boolean rep;
}
@end

@implementation UUAVAudioPlayer

+ (UUAVAudioPlayer *)sharedInstance
{
    static UUAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)playSongWithUrl:(NSString *)songUrl
{
    
    dispatch_async(dispatch_queue_create("playSoundFromUrl", NULL), ^{
        [self.delegate UUAVAudioPlayerBeiginLoadVoice];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:songUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playSoundWithData:data];
        });
    });
    
}

-(void)playSongWithData:(NSData *)songData
{
    
    [self setupPlaySound];
    [self playSoundWithData:songData];
    
}

-(void)playSoundWithData:(NSData *)soundData{
    
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self->countDownTimer invalidate];
        self->countDownTimer = nil;
        
    });
    
    NSError *playerError;
    _player = [[AVAudioPlayer alloc]initWithData:soundData error:&playerError];
    _player.volume = 1.0f;
    if (_player == nil){
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    
    _player.delegate = self;
    [_player play];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];
        
    });
    
    
    NSLog(@"time : %f",[_player currentTime]);
    
    [self.delegate UUAVAudioPlayerBeiginPlay];
    
}

- (void)updateTimeLeft
{
    
    //    NSTimeInterval timeLeft = self.player.duration - self.player.currentTime;
    
    //    int min = timeLeft/60;
    
    //    int sec = lroundf(timeLeft) % 60;
    
    //    NSLog(@"time : %d %d",min,sec);
    
    [self.delegate playerTime:self.player.duration Currentime:self.player.currentTime];
    
}


-(void)playerTime:(NSString *)songData{
    
    NSLog(@"time : %f",[_player currentTime]);
    
}


-(void)setupPlaySound
{
    
    UIApplication *app = [UIApplication sharedApplication];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
    //    if(self.player.currentTime == self.player.duration)
    //    {
    [self.delegate UUAVAudioPlayerDidFinishPlay:false];
    //    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self->countDownTimer invalidate];
        self->countDownTimer = nil;
        
    });
    [self.delegate playerTime:self.player.duration Currentime:0.00];
}

-(void)pause{
    
    if(countDownTimer){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self->countDownTimer invalidate];
            self->countDownTimer = nil;
            
        });
        
        [_player pause];
    }
    
    
}

- (void)stopSound
{
    
    if (_player && _player.isPlaying) {
        
        if(self->countDownTimer){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self->countDownTimer invalidate];
                self->countDownTimer = nil;
                
            });
            
            [_player stop];
            
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    [self.delegate UUAVAudioPlayerDidFinishPlay:false];
}

@end
