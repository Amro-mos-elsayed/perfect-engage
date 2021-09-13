





//
//  UUMessage.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessage.h"
#import "NSDate+Utils.h"

@implementation UUMessage
- (instancetype)init
{
    self = [super init];
    if (self) {
        _Messageheight = 44.0;
        
    }
    return self;
}
- (void)setWithDict:(NSDictionary *)dict{
    
    //    self.strName = dict[@"strName"];
    //    self.strId = dict[@"strId"];
    //    self.strTime = [self changeTheDateString:dict[@"strTime"]];
    self.from = [dict[@"message_from"] intValue];
    
    self.isLastMessage = dict[@"isLastMessage"];
    switch ([dict[@"type"] integerValue]) {
        case 0:
            if(dict[@"theme_color"])
            {
                self.theme_color = dict[@"theme_color"];
            }
            if(dict[@"theme_font"])
            {
                self.theme_font = dict[@"theme_font"];
            }
            self.type = UUMessageTypeText;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.user_common_id = dict[@"user_common_id"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.is_viewed = dict[@"is_viewed"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 1:
            self.type = UUMessageTypePicture;
            self.picture = dict[@"picture"];
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.user_common_id = dict[@"user_common_id"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.is_viewed = dict[@"is_viewed"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 2:
            self.type = UUMessageTypeVideo;
            self.picture = dict[@"picture"];
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.user_common_id = dict[@"user_common_id"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.is_viewed = dict[@"is_viewed"];
            self.reply_type = dict[@"reply_type"];
            if(dict[@"duration"])
            {
                self.duration = [dict[@"duration"] isEqualToString:@""] ? @"0" : dict[@"duration"];
            }
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 3:
            self.type = UUMessageTypeVoice;
            self.picture = dict[@"picture"];
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.user_common_id = dict[@"user_common_id"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 4:
            
            self.type = UUMessageTypeLink;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self.Title_str= dict[@"title"];
            self.ImageURl= dict[@"image_url"];
            self.Desc= dict[@"desc"];
            self.Url_str=dict[@"url_str"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.message_type = dict[@"type"];
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 5:
            self.type = UUMessageTypeContact;
            self.strContent = dict[@"payload"];
            self.contact_name = dict[@"contact_name"];
            self.contact_phone = dict[@"contact_phone"];
            self.contact_profile = dict[@"contact_profile"];
            self.contact_id = dict[@"contact_id"];
            self.contact_details = dict[@"contact_details"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 6:
            self.type = UUMessageTypeDocument;
            self.picture = dict[@"picture"];
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.docType= dict[@"docType"];
            self.docName= dict[@"docName"];
            self.docPageCount= dict[@"docPageCount"];
            self.message_type = dict[@"type"];
            self.user_common_id = dict[@"user_common_id"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 20:
            self.type = UUMessageTypeDocument;
            self.picture = dict[@"picture"];
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.docType= dict[@"docType"];
            self.docName= dict[@"docName"];
            self.docPageCount= dict[@"docPageCount"];
            self.message_type = dict[@"type"];
            self.user_common_id = dict[@"user_common_id"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 7:
            self.type = UUMessageTypeReply;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.user_common_id = dict[@"user_common_id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 14:
            
            self.type = UUMessageTypeLocation;
            self.picture = dict[@"picture"];
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self.user_common_id = dict[@"user_common_id"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self._id=dict[@"id"];
            self.contactmsisdn = dict[@"contactmsisdn"];
            self.imagelink  = dict[@"imagelink"];
            self.latitude= dict[@"latitude"];
            self.longitude= dict[@"longitude"];
            self.title_place = dict[@"title_place"];
            self.Stitle_place = dict[@"Stitle_place"];
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 21:
            self.type = UUMessageTypeReply;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.user_common_id = dict[@"user_common_id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 13:
            self.type = UUMessageTypeText;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.user_common_id = dict[@"user_common_id"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
        case 23:
            self.type = UUMessageTypeReply;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.user_common_id = dict[@"user_common_id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
            
        case 71:
            self.type = UUMessageTypeReply;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.user_common_id = dict[@"user_common_id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
            
        case 72:
            self.type = UUMessageTypeReply;
            self.strContent = dict[@"payload"];
            self.conv_id= dict[@"convId"];
            self.doc_id= dict[@"doc_id"];
            self.filesize= dict[@"filesize"];
            self.user_from= dict[@"from"];
            self.isStar= dict[@"isStar"];
            self.message_status= dict[@"message_status"];
            self.msgId= dict[@"msgId"];
            self.name= dict[@"name"];
            self.payload= dict[@"payload"];
            self.recordId= dict[@"recordId"];
            self.thumbnail= dict[@"thumbnail"];
            self.timestamp= dict[@"timestamp"];
            self.to= dict[@"to"];
            self.width= dict[@"width"];
            self.height= dict[@"height"];
            self.chat_type= dict[@"chat_type"];
            self.info_type= dict[@"info_type"];
            self._id=dict[@"id"];
            self.user_common_id = dict[@"user_common_id"];
            self.contactmsisdn= dict[@"contactmsisdn"];
            self.Progress = @"0.0";
            self.message_type = dict[@"type"];
            self.imagelink  = @"";
            self.latitude= @"";
            self.longitude= @"";
            self.title_place = @"";
            self.Stitle_place = @"";
            self.is_deleted = dict[@"is_deleted"];
            self.reply_type = dict[@"reply_type"];
            self.while_blocked = dict[@"while_blocked"];
            break;
            
        default:
            break;
    }
}

- (NSString *)changeTheDateString:(NSString *)Str
{
    NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
    NSDate *lastDate = [NSDate dateFromString:subString withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:lastDate];
    lastDate = [lastDate dateByAddingTimeInterval:interval];
    
    NSString *dateStr;
    NSString *period;
    NSString *hour;
    if ([lastDate year]==[[NSDate date] year]) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        if (days <= 2) {
            dateStr = [lastDate stringYearMonthDayCompareToday];
        }else{
            dateStr = [lastDate stringMonthDay];
        }
    }else{
        dateStr = [lastDate stringYearMonthDay];
    }
    if ([lastDate hour]>=5 && [lastDate hour]<12) {
        period = @"AM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }else if ([lastDate hour]>=12 && [lastDate hour]<=18){
        period = @"PM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else if ([lastDate hour]>18 && [lastDate hour]<=23){
        period = @"Night";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else{
        period = @"Dawn";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }
    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
}

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end
{
    if (!start) {
        self.showDateLabel = YES;
        return;
    }
    
    NSString *subStart = [start substringWithRange:NSMakeRange(0, 19)];
    NSDate *startDate = [NSDate dateFromString:subStart withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *subEnd = [end substringWithRange:NSMakeRange(0, 19)];
    NSDate *endDate = [NSDate dateFromString:subEnd withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //这个是相隔的秒数
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    //相距5分钟显示时间Label
    if (fabs (timeInterval) > 5*60) {
        self.showDateLabel = YES;
    }else{
        self.showDateLabel = NO;
    }
    
}
@end

