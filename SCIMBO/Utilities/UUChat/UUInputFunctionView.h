//
//  UUInputFunctionView.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@class UUInputFunctionView;

@protocol UUInputFunctionViewDelegate <NSObject>
 // text
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message;
 // image
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image;
 // audio
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView TextViewDidchange:(NSString *)Text;
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
 - (void)CallActionSheet;


@end

@interface UUInputFunctionView : UIView <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UIButton *btnSendMessage;
@property (nonatomic, retain) IBOutlet UIButton *btnChangeVoiceState;
@property (nonatomic, retain) IBOutlet UIButton *btnVoiceRecord;

@property (nonatomic, strong) IBOutlet HPGrowingTextView *textView;

@property (nonatomic, retain) IBOutlet UIButton *cameraBtn;
@property (nonatomic, retain) IBOutlet UIButton *plusBtn;
@property (nonatomic, retain) UIButton *dotImageView;

@property (nonatomic, retain) IBOutlet UIButton *RecordBtn;




@property (nonatomic, assign) BOOL isAbleToSendTextMessage;

@property (nonatomic, weak) id<UUInputFunctionViewDelegate>delegate;


-(void)setVC;
-(void)changeSendBtnWithPhoto:(BOOL)isPhoto;
-(void)set_Frame;
-(void)become_FirtResponder;
-(void)resign_FirtResponder;


@end
