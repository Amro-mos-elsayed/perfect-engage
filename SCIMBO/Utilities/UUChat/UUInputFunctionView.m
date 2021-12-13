//
//  UUInputFunctionView.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUInputFunctionView.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ACMacros.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface UUInputFunctionView ()<UITextViewDelegate, Mp3RecorderDelegate, HPGrowingTextViewDelegate>
{
    BOOL isbeginVoiceRecord;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    
    UILabel *placeHold;
    BOOL isSendBtnShown;
    float _currentKeyboardHeight;
}
@end

@implementation UUInputFunctionView

-(void)setVC
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    CGRect frame = CGRectMake(0, Main_Screen_Height-50, Main_Screen_Width, 50);
    self.frame = frame;
    //    self = [super initWithFrame:frame];
    //    if (self) {
    MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
    
    self.isAbleToSendTextMessage = YES;
    
    self.btnSendMessage.hidden = true;
    
    [self.btnSendMessage addTarget:self action:@selector(sendMessageTxt:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnChangeVoiceState addTarget:self action:@selector(voiceRecord:) forControlEvents:UIControlEventTouchDown];
    
    [self.cameraBtn addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.plusBtn addTarget:self action:@selector(plusAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnChangeVoiceState addTarget:self action:@selector(voiceRecord:) forControlEvents:UIControlEventTouchDown];
    [self.btnChangeVoiceState addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnChangeVoiceState addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.btnChangeVoiceState addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [self.btnChangeVoiceState addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    
    isbeginVoiceRecord = NO;
    
    self.btnVoiceRecord.hidden = YES;
    
    [self.btnVoiceRecord setTitle:@"< Slide to cancel" forState:UIControlStateNormal];
    
    _RecordBtn.hidden = true;
    
    self.dotImageView.hidden = false;
    
    [self set_Frame];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(growingTextViewDidEndEditing:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateKeyboardFrame:) name:UIKeyboardWillShowNotification object:nil];
    
    [self addTextView];
    
    
    //    }
    //    return self;
}

- (void)keyboardWillShow:(NSNotification *)userinfo {
    [self growingTextViewDidChange:self.textView];
}

- (void)keyboardWillHide:(NSNotification *)userinfo {
    [self growingTextViewDidChange:self.textView];
}

-(void)addTextView
{
    _textView.isScrollable = NO;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    _textView.minNumberOfLines = 1;
    _textView.maxNumberOfLines = 6;
    _textView.returnKeyType = UIReturnKeyGo; //just as an example
    _textView.font = [UIFont systemFontOfSize:15.0];
    _textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.backgroundColor = [UIColor clearColor];
    _textView.placeholder = @"";
    
    //textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.enablesReturnKeyAutomatically = YES;
    //textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, -1.0, 0.0, 1.0);
    //textView.textContainerInset = UIEdgeInsetsMake(8.0, 4.0, 8.0, 0.0);
    _textView.layer.cornerRadius = 5.0;
    _textView.layer.borderWidth = 0.8;
    _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
     NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *firsttwo = [language substringToIndex:2];
    _textView.textAlignment = [firsttwo  isEqualToString: @"ar"] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
}

-(void)updateKeyboardFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _currentKeyboardHeight = kbSize.height;
    
}

-(void)become_FirtResponder
{
    [_textView becomeFirstResponder];
    
}

-(void)resign_FirtResponder
{
    [_textView resignFirstResponder];
    
}

-(void)set_Frame
{
    if(!self.btnSendMessage.isHidden){
        self.dotImageView.hidden=true;
        self.btnVoiceRecord.hidden=true;
        self.btnChangeVoiceState.hidden=true;
        self.cameraBtn.hidden = true;
    }else{
        self.dotImageView.hidden=true;
        self.btnVoiceRecord.hidden=true;
        self.btnChangeVoiceState.hidden=false;
        self.cameraBtn.hidden = true;
    }
}

#pragma mark - 录音touch事件
- (void)beginRecordVoice:(UIButton *)button
{
    if( [self audioAccessPermission]) {
    
    _btnVoiceRecord.hidden = false;
    _textView.hidden = true;
    
    _RecordBtn.hidden = false;
    _plusBtn.hidden = true;
    
    
    
    [MP3 startRecord];
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
    //    [UUProgressHUD show];
    }else {
        [self showAlertAudioPermission];
    }
}

- (BOOL) audioAccessPermission
{
    switch ([[AVAudioSession sharedInstance] recordPermission]) {
        case AVAudioSessionRecordPermissionGranted:
            return YES;
        case AVAudioSessionRecordPermissionDenied:
            return NO;
        case AVAudioSessionRecordPermissionUndetermined:
            return YES;
    }
}

- (void)endRecordVoice:(UIButton *)button
{
    if (playTimer) {
        [MP3 stopRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    if(playTime > 1)
    {
        [self.btnVoiceRecord setTitle:@"Recorded..." forState:UIControlStateNormal];
    }
    [self performSelector:@selector(ClearRecordComponents) withObject:self afterDelay:1.0];
    
    
    
}

- (void)cancelRecordVoice:(UIButton *)button
{
    if (playTimer) {
        [MP3 cancelRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    [self.btnVoiceRecord setTitle:@"Cancelled" forState:UIControlStateNormal];
    
    //    [UUProgressHUD dismissWithError:@"Cancel"];
    [self performSelector:@selector(ClearRecordComponents) withObject:self afterDelay:1.0];
    
    
}

-(void)ClearRecordComponents
{
    _btnVoiceRecord.hidden = true;
    _textView.hidden = false;
    _RecordBtn.hidden = true;
    _plusBtn.hidden = false;
}

-(void)BlinkAnimation
{
    _RecordBtn.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
                         // [pin setTransform:CGAffineTransformMakeTranslation(0, 20)];
                         _RecordBtn.alpha = 1.0;
                         
                     }completion:^(BOOL finished){
                         
                     }];
    
}


- (void)RemindDragExit:(UIButton *)button
{
    
    //    [UUProgressHUD changeSubTitle:@"Release to cancel"];
}

- (void)RemindDragEnter:(UIButton *)button
{
    
    //    [UUProgressHUD changeSubTitle:@"Slide up to cancel"];
}


- (void)countVoiceTime
{
    playTime ++;
    int seconds = playTime % 60;
    int minutes = (playTime / 60) % 60;
    //    int hours = playTime / 3600;
    
    [self.btnVoiceRecord setTitle:[NSString stringWithFormat:@" %02d:%02d < Slide to cancel",minutes,seconds] forState:UIControlStateNormal];
    
    if (playTime>=180) {
        [self endRecordVoice:nil];
    }
}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData
{
    [self.delegate UUInputFunctionView:self sendVoice:voiceData time:playTime+1];
    //    [UUProgressHUD dismissWithSuccess:@"Success"];
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

- (void)failRecord
{
    [self.btnVoiceRecord setTitle:@"Too short" forState:UIControlStateNormal];
    
    //    [UUProgressHUD dismissWithSuccess:@"Too short"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}
- (void)beginConvert{
    NSLog(@"Start Conversion转换");
    //    [UUProgressHUD changeSubTitle:@"Converting..."];
}

//改变输入与录音状态
- (void)voiceRecord:(UIButton *)sender
{
    
    
    
    AudioServicesPlaySystemSound(0);
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    _cameraBtn.hidden = true;
    self.btnVoiceRecord.hidden = !self.btnVoiceRecord.hidden;
    _textView.hidden = !_textView.hidden;
    
    _RecordBtn.hidden = false;
    [self.btnVoiceRecord setTitle:[NSString stringWithFormat:@" 00:00 < Slide to cancel"] forState:UIControlStateNormal];
    
    isbeginVoiceRecord = !isbeginVoiceRecord;
    [self.textView resignFirstResponder];
    self.btnVoiceRecord.highlighted = false;
    [self BlinkAnimation];
    [self beginRecordVoice:self.btnVoiceRecord];
    
}

- (void) showAlertAudioPermission
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"App needs a permission to record audio.", @"") preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    
    id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if([rootViewController isKindOfClass:[UINavigationController class]])
    {
        rootViewController = ((UINavigationController *)rootViewController).viewControllers.firstObject;
    }
    if([rootViewController isKindOfClass:[UITabBarController class]])
    {
        rootViewController = ((UITabBarController *)rootViewController).selectedViewController;
    }
    //...
    [rootViewController presentViewController:alert animated:YES completion:nil];
}


- (void)cameraAction:(UIButton *)sender
{
    [self.textView resignFirstResponder];
    
//    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Images",nil];
//    [actionSheet showInView:self.window];
}
- (void)plusAction:(UIButton *)sender
{
    [self.textView resignFirstResponder];
    
    if([self.delegate respondsToSelector:@selector(CallActionSheet)])
    {
        [self.delegate CallActionSheet];
    }
    
    
}


//发送消息（文字图片）
- (void)sendMessageTxt:(UIButton *)sender
{
    if (self.isAbleToSendTextMessage) {
        NSString *resultStr = [self.textView.text stringByReplacingOccurrencesOfString:@"   " withString:@""];
        
        [self ShowrecordComponents];
        [self.delegate UUInputFunctionView:self sendMessage:resultStr];
    }
    else{
        [self.textView resignFirstResponder];
        
//        UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Images",nil];
//        [actionSheet showInView:self.window];
    }
}

-(void)ShowrecordComponents
{
    placeHold.hidden = self.textView.text.length > 0;
    self.btnSendMessage.alpha = 0.0;
    self.cameraBtn.alpha=1.0;
    isSendBtnShown = false;
    
    self.btnChangeVoiceState.hidden = false;
    self.cameraBtn.hidden = true;
    self.dotImageView.hidden = true;
    self.btnSendMessage.hidden = true;

//    [UIView animateWithDuration:0.0 animations:^{
//        self.btnSendMessage.alpha=0.0;
//        self.cameraBtn.alpha=1.0;
//    } completion:^(BOOL finished) {
//    }];
    
}

- (void)changeSendBtnWithPhoto:(BOOL)isPhoto
{
    self.isAbleToSendTextMessage = true;
    
}



#pragma mark - TextViewDelegate

-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
}
-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if(self.btnSendMessage.isHidden)
    {
        placeHold.hidden = self.textView.text.length > 0;
        self.btnSendMessage.alpha=0.0;
        self.cameraBtn.alpha=1.0;
        
        isSendBtnShown = false;
        self.btnChangeVoiceState.hidden = false;
        self.cameraBtn.hidden = true;
        self.dotImageView.hidden = true;
        self.btnSendMessage.hidden = true;
//        [UIView animateWithDuration:0.0 animations:^{
//            self.btnSendMessage.alpha=0.0;
//            self.cameraBtn.alpha=1.0;
//        } completion:^(BOOL finished) {
//            isSendBtnShown = false;
//            self.btnChangeVoiceState.hidden = false;
//            self.cameraBtn.hidden = true;
//            self.dotImageView.hidden = true;
//            self.btnSendMessage.hidden = true;
//        }];
    }
    else
    {
        self.btnChangeVoiceState.hidden = true;
        
        self.btnChangeVoiceState.hidden = true;
        
        self.btnSendMessage.hidden = false;
        
    }
    //if (![textView.text  isEqual: @""]){
    placeHold.hidden = self.textView.text.length > 0;
}


-(void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    if(self.btnSendMessage.isHidden)
    {
        placeHold.hidden = self.textView.text.length > 0;
        self.btnSendMessage.alpha=0.0;
        self.cameraBtn.alpha=1.0;
        
        isSendBtnShown = false;
        
        self.btnChangeVoiceState.hidden = false;
        self.cameraBtn.hidden = true;
        self.dotImageView.hidden = true;
        self.btnSendMessage.hidden = true;
//        [UIView animateWithDuration:0.0 animations:^{
//            self.btnSendMessage.alpha=0.0;
//            self.cameraBtn.alpha=1.0;
//        } completion:^(BOOL finished) {
//            isSendBtnShown = false;
//
//            self.btnChangeVoiceState.hidden = false;
//            self.cameraBtn.hidden = true;
//            self.dotImageView.hidden = true;
//            self.btnSendMessage.hidden = true;
//        }];
    }
    else
    {
        self.btnChangeVoiceState.hidden = true;
        
        self.btnChangeVoiceState.hidden = true;
        
        self.btnSendMessage.hidden = false;
        
    }
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    [self changeSendBtnWithPhoto:self.textView.text.length>0?NO:YES];
    placeHold.hidden = self.textView.text.length>0;
    
    [self.delegate UUInputFunctionView:self TextViewDidchange:self.textView.text];
    
    if(self.textView.text.length>0)
    {
        
        if(!isSendBtnShown)
        {
            self.btnSendMessage.alpha=1.0;
            self.cameraBtn.alpha=0.0;
            
            isSendBtnShown = true;
            self.btnChangeVoiceState.hidden = true;
            self.cameraBtn.hidden = true;
            self.dotImageView.hidden = true;
            self.btnSendMessage.hidden = false;
//            [UIView animateWithDuration:0.0 animations:^{
//                self.btnSendMessage.alpha=1.0;
//                self.cameraBtn.alpha=0.0;
//            } completion:^(BOOL finished) {
//                isSendBtnShown = true;
//                self.btnChangeVoiceState.hidden = true;
//                self.cameraBtn.hidden = true;
//                self.dotImageView.hidden = true;
//                self.btnSendMessage.hidden = false;
//            }];
            
        }
    }
    else
    {
        isSendBtnShown=false;
        self.btnSendMessage.alpha=0.0;
        self.cameraBtn.alpha=1.0;
        
        self.btnChangeVoiceState.hidden = false;
        self.cameraBtn.hidden = true;
        self.dotImageView.hidden = true;
        self.btnSendMessage.hidden = true;
//        [UIView animateWithDuration:0.0 animations:^{
//            self.btnSendMessage.alpha=0.0;
//            self.cameraBtn.alpha=1.0;
//            
//        } completion:^(BOOL finished) {
//            self.btnChangeVoiceState.hidden = false;
//            self.cameraBtn.hidden = true;
//            self.dotImageView.hidden = true;
//            self.btnSendMessage.hidden = true;
//        }];
        
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self.delegate UUInputFunctionView:self shouldChangeTextInRange:range replacementText:text];
    return YES;
}



#pragma mark - Add Picture

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = YES;
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self.superVC presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
//        [alert show];
    }
}

-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = YES;
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        [self.superVC presentViewController:picker animated:YES completion:^{
//        }];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
//    [self.superVC dismissViewControllerAnimated:YES completion:^{
//        [self.delegate UUInputFunctionView:self sendPicture:editImage];
//    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
//    [self.superVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

