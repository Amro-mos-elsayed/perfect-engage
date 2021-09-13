//
//  UUMessage.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MessageType) {
    UUMessageTypeText     = 0,
    UUMessageTypePicture  = 1,
    UUMessageTypeVideo  = 2,
    UUMessageTypeVoice    = 3,
    UUMessageTypeLink     = 4,
    UUMessageTypeContact    = 5,
    UUMessageTypeDocument    = 6,
    UUMessageTypeReply    = 7,
    UUMessageTypeLocation = 14,
    UUMessageTypeMissedCall = 21,
};


typedef NS_ENUM(NSInteger, MessageFrom) {
    UUMessageFromMe    = 1,   // 自己发的
    UUMessageFromOther = 0    // 别人发得
};

@interface UUMessage : NSObject
@property (nonatomic, copy) NSString *strTime;

@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) UIImage  *picture;
@property (nonatomic, copy) NSData   *voice;
@property (nonatomic, copy) NSString *strVoiceTime;
@property (nonatomic, copy) NSString *docType;
@property (nonatomic, copy) NSString *docName;
@property (nonatomic, copy) NSString *docPageCount;
@property (nonatomic, copy) NSString *docSize;

@property (nonatomic, copy) NSString *conv_id;
@property (nonatomic, copy) NSString *doc_id;
@property (nonatomic, copy) NSString *filesize;
@property (nonatomic, copy) NSString * user_from;//from
@property (nonatomic, copy) NSString * messageid;//id
@property (nonatomic, copy) NSString * isStar;
@property (nonatomic, copy) NSString *message_status;
@property (nonatomic, copy) NSString * msgId;

@property (nonatomic, copy) NSString * name;//id
@property (nonatomic, copy) NSString * payload;
@property (nonatomic, copy) NSString *recordId;
@property (nonatomic, copy) NSString * server_load;


@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString * time;
@property (nonatomic, copy) NSString * timestamp;

@property (nonatomic, copy) NSString * theme_color;
@property (nonatomic, copy) NSString * theme_font;

@property (nonatomic, copy) NSString * Title_str;
@property (nonatomic, copy) NSString * ImageURl;
@property (nonatomic, copy) NSString * Desc;
@property (nonatomic, copy) NSString * Url_str;

@property (nonatomic, copy) NSString * height;
@property (nonatomic, copy) NSString * chat_type;
@property (nonatomic, copy) NSString * info_type;
@property (nonatomic, copy) NSString * _id;
@property (nonatomic, copy) NSString * contactmsisdn;

@property (nonatomic, copy) NSString * contact_name;
@property (nonatomic, copy) NSString * contact_phone;
@property (nonatomic, copy) NSString * contact_profile;
@property (nonatomic, copy) NSString * contact_id;
@property (nonatomic, copy) NSString * contact_details;

@property (assign, nonatomic) CGFloat Messageheight;

@property (nonatomic, copy) NSString * Progress;
@property (nonatomic, copy) NSString * user_common_id;
@property (nonatomic, copy) NSString * imagelink;

@property (nonatomic, copy) NSString * to;//to
@property (nonatomic, copy) NSString * message_type; //type
@property (nonatomic, copy) NSString *width; //

@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) MessageFrom from;

@property (nonatomic, assign) BOOL showDateLabel;

- (void)setWithDict:(NSDictionary *)dict;

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;
@property (nonatomic, strong) NSString* latitude;
@property (nonatomic, strong) NSString* longitude;
@property (nonatomic, strong) NSString* title_place;
@property (nonatomic, strong) NSString* Stitle_place;
@property (nonatomic, strong) NSString* is_deleted;
@property (nonatomic, strong) NSString* is_viewed;
@property (nonatomic, strong) NSString* reply_type;
@property (nonatomic, strong) NSString* readmore_count;
@property (nonatomic, assign) BOOL isLastMessage;

@property (nonatomic, strong) NSString* duration;
@property (nonatomic, strong) NSString* while_blocked;
@end
