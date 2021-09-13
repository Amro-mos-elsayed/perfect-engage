//
//  UUMessageFrame.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageFrame.h"
#import "UUMessage.h"
#import <UIKit/UIKit.h>



@implementation UUMessageFrame

- (void)setMessage:(UUMessage *)message{
 
    _message = message;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    // 1、计算时间的位置
    if (_showTime){
        CGFloat timeY = ChatMargin;
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary *sizeAttributes        = @{NSFontAttributeName:ChatTimeFont, NSParagraphStyleAttributeName: style};
        CGSize adjustedSize = CGSizeMake(300, 100);
        CGRect rect = [_message.strTime boundingRectWithSize:adjustedSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:sizeAttributes
                                                 context:nil];

       CGSize timeSize =  rect.size;
        
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
    }
    
    
    // 2、计算头像位置
    CGFloat iconX = ChatMargin;
    if (_message.from == UUMessageFromMe) {
        iconX = screenW - ChatMargin - ChatIconWH;
    }
    CGFloat iconY = CGRectGetMaxY(_timeF) + ChatMargin;
    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);
    
    // 3、计算ID位置
    _nameF = CGRectMake(iconX, iconY+ChatIconWH, ChatIconWH, 20);
    
    // 4、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
    CGFloat contentY = iconY;
    
    //根据种类分
    CGSize contentSize;
    switch (_message.type) {
        case UUMessageTypeText:
        {
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [style setLineBreakMode:NSLineBreakByCharWrapping];
            NSDictionary *sizeAttributes        = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0], NSParagraphStyleAttributeName: style};
            CGSize adjustedSize = CGSizeMake(ChatContentW, CGFLOAT_MAX);
            CGRect rect = [_message.strContent boundingRectWithSize:adjustedSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:sizeAttributes
                                                         context:nil];
            
            
            contentSize = rect.size;
 //            _textView.text = messageFrame.message.payload
//            _textView.sizeToFit()

            
            break;
        }
        case UUMessageTypePicture:
            contentSize = CGSizeMake(ChatPicWH, ChatPicWH);
            break;
        case UUMessageTypeVoice:  
            if (IS_IPHONE_5S)  {
                contentSize = CGSizeMake(180, 10);
            }
            else
            {
                contentSize = CGSizeMake(250, 20);
            }
            break;
        default:
            break;
    }
    _ContentSize=0.0;
    UIViewAutoresizing autoresizing;
    _textView = [[UITextView alloc] init];
    CGFloat max_witdh = 0.7 * 320;
    _textView.frame = CGRectMake(0, 0, max_witdh, MAXFLOAT);

     if (_message.from == UUMessageFromMe) {
        contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
        _ContentSize=8;
        _textView.text = _message.strContent;
        [_textView sizeToFit];

        autoresizing = UIViewAutoresizingFlexibleLeftMargin;
        _textView.autoresizingMask = autoresizing;
         _contentF = CGRectMake(contentX, 0, contentSize.width + ChatContentLeft + ChatContentRight, _textView.frame.size.height );
    }
    else
    {
        _textView.text = _message.strContent;
        [_textView sizeToFit];
         _ContentSize=8;
        autoresizing = UIViewAutoresizingFlexibleRightMargin;
        _textView.autoresizingMask = autoresizing;
        _contentF = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight, _textView.frame.size.height + ChatContentTop + ChatContentBottom+_ContentSize);
        

    }
    if(_message.type == UUMessageTypeText)
    {
        _cellHeight = _message.Messageheight;
    }
    else
    {
         _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF))  + ChatMargin;
    }

    
 }

@end
