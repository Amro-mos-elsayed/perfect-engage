//
//  Constant.swift
//
//
//  Created by CASPERON on 29/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import Foundation
//let BaseURLArray = ["https://2ppee.perfect-engage.com"]// gitex

//let BaseURLArray = ["https://pee.perfect-engage.com"]// minister
let BaseURLArray = ["https://dev2pengage.perfect-engage.com"]

var BaseUrl : String {
    get {
        return Themes.sharedInstance.getURL() + "/api"
    }
}

var ImgUrl : String {
    get {
        return Themes.sharedInstance.getURL()
    }
}

var SocketCreateRoomUrl : String {
    get {
        return Themes.sharedInstance.getURL()
    }
}

var webUrl : String {
    get {
        return Themes.sharedInstance.getURL() + "/web"
    }
}

class Constant : NSObject
{
    static let sharedinstance = Constant()
    
    let Datausagesetting = [["Left" : "Photos", "Right" : "2"], ["Left" : "Audio", "Right" : "1"], ["Left" : "Videos", "Right" : "1"], ["Left" : "Documents", "Right" : "1"], ["Left" : "Reset Auto-Download Settings", "Right" : ""]]
    
    var Settings : String {
        get {
            return "\(BaseUrl)/settings"
        }
    }
    var RegisterNo : String {
        get {
            return "\(BaseUrl)/Login"
        }
    }
    var RegisterGuestNo : String {
        get {
            return "\(BaseUrl)/loginAsAGuest"
        }
    }
    var confirmOTP : String {
        get {
            return "\(BaseUrl)/VerifyMsisdn"
        }
    }
    var UpdateData : String {
        get {
            return "\(BaseUrl)/UpdateData"
        }
    }
    var UploadBackupFile : String {
          get {
              return "\(BaseUrl)/UploadBackupFile"
          }
      }
    var getBackupFile : String {
           get {
               return "\(BaseUrl)/GetBackupFile"
           }
       }
    var ResendInvitecode : String {
        get {
            return "\(BaseUrl)/ResendInvitecode"
        }
    }
    var startFileuploadNotification : String {
        get {
            return "\(BaseUrl.replacingOccurrences(of: "/api", with: ""))/startFileuploadNotification"
        }
    }
    //let AppGroupID = "group.com.2p.swcc"
    let AppGroupID = AppGroupConstants.AppGroupID
    let GoogleMapKey = "AIzaSyBJkky3R5AzhiINV-_WhxSCWYi4K69jyBU"
    let Connect:String = "connect"
    let network_disconnect:String = "disconnect"
    let network_error:String = "error"
    let create_user:String = "create_user"
    let usercreated:String = "usercreated"
    let userauthenticated:String = "userauthenticated"
    let sc_check_secret_keys:String = "sc_check_secret_keys"
    let sc_get_offline_messages:String = "sc_get_offline_messages"
    let group:String = "group"
    let sc_message_response:String = "sc_message_response"
    let sc_message:String = "sc_message"
    let sc_media_status:String = "sc_media_status"
    let sc_media_status_response:String = "sc_media_status_response"
    let sc_media_status_ack:String = "sc_media_status_ack"
    let sc_get_offline_status:String = "sc_get_offline_status"
    let sc_media_message_status_update:String = "sc_media_message_status_update"
    let sc_remove_media_status:String = "sc_remove_media_status"
    let sc_mute_status:String = "sc_mute_status"
    let sc_media_status_privacy:String = "sc_media_status_privacy"
    let sc_get_secret_keys:String = "sc_get_secret_keys"
    let sc_new_room_connection:String="sc_new_room_connection"
    let sc_change_new_security_code:String="sc_change_new_security_code"
    let sc_clear_user_db:String="sc_clear_user_db"
    let sc_clear_single_user_chat:String="sc_clear_single_user_chat"
    let sc_settings:String = "sc_settings"
    let sc_typing:String = "sc_typing"
    let sc_message_ack:String = "sc_message_ack"
    let sc_contacts:String = "sc_contacts"
    let GetPhoneContact:String = "GetPhoneContact"
    let getAllContacts = "GetAllContacts"
    let sc_online_status:String = "getCurrentTimeStatus"
    let sc_change_status:String = "sc_change_status"
    let sc_change_online_status:String = "sc_change_online_status"
    let sc_skipbackup_messages:String = "sc_skipbackup_messages"
    let sc_uploadImage = "app"+"/"+"fileUpload"
    let sc_recev_ImagePath = "app"+"/"+"received"
    let getFilesizeInBytes = "app"+"/"+"getFilesizeInBytes"
    let sc_changeProfilePic:String = "uploadImage"
    let appgetGroupList:String = "app"+"/"+"getGroupList"
    let getGroupDetails:String = "getGroupDetails"
    let remove_user:String = "remove_user"
    let sc_changeStatus = "changeProfileStatus"
    let sc_changeName:String = "changeName"
    let GetMobileSettings:String = "GetMobileSettings"
    let sc_call_reconnect_hold: String = "sc_call_reconnect_hold"
    let sc_call_reconnect_intimate: String = "sc_call_reconnect_intimate"
    let qrdata:String = "qrdata"
    let qrdataresponse:String = "qrdataresponse"
    let sc_get_server_time:String = "sc_get_server_time"
    let sc_get_user_Details:String = "sc_get_user_Details"
    let sc_message_status_update:String = "sc_message_status_update"
    let sc_delete_chat:String = "sc_delete_chat"
    let sc_archived_chat:String = "sc_archived_chat"
    let sc_marked_chat:String = "sc_marked_chat"
    let sc_to_conv_settings:String = "sc_to_conv_settings"
    let sc_app_settings:String = "sc_app_settings"
    let sc_report_spam_user:String = "sc_report_spam_user"
    let sc_block_user:String = "sc_block_user"
    let sc_call:String = "sc_call"
    let sc_call_response:String = "sc_call_response"
    let sc_call_retry:String = "sc_call_retry"
    let sc_get_call_status:String = "sc_get_call_status"
    let sc_call_ack:String = "sc_call_ack"
    let sc_call_status:String = "sc_call_status"
    let sc_call_status_response:String = "sc_call_status_response"
    let sc_privacy_settings:String = "sc_privacy_settings"
    let sc_delete_account:String = "sc_delete_account"
    let mobileToWebLogout:String = "mobileLogout"
    let mobileLogout:String = "mobileLogout"
    let checkMobileLoginKey:String = "checkMobileLoginKey"
    let sc_change_mail:String = "sc_change_email"
    let sc_change_recovery_email:String = "sc_change_recovery_email"
    let sc_change_recovery_phone:String = "sc_change_recovery_phone"
    let sc_chat_lock:String = "sc_chat_lock"
    let sc_set_mobile_password_chat_lock:String = "sc_set_mobile_password_chat_lock"
    let getMessageInfo:String = "getMessageInfo"
    let sc_mute_chat:String = "sc_mute_chat"
    let sc_change_timer:String = "sc_change_timer"
    let sc_remove_message_everyone:String = "sc_remove_message_everyone"
    let sc_get_offline_deleted_messages:String = "sc_get_offline_deleted_messages"
    let sc_deleted_message_ack:String = "sc_deleted_message_ack"
    let RemovedByAdmin:String = "RemovedByAdmin"
    let sc_clear_chat:String = "sc_clear_chat"
    let RemoveMessage:String = "RemoveMessage"
    let StarMessage:String = "StarMessage"
    let ReplyMessage:String = "ReplyMessage"
    let updateMobilePushNotificationKey:String = "updateMobilePushNotificationKey"
    let sc_group_offline_message:String = "sc_group_offline_message"
    let sc_group_offline_deleted_message:String = "sc_group_offline_deleted_message"
    let sc_file_upload_notify:String = "sc_file_upload_notify"
    let ForwardMessage:String = "ForwardMessage"
    let sc_user_offline_in_call:String = "sc_user_offline_in_call"
    let sc_webrtc_turn_message:String="sc_webrtc_turn_message"
    let sc_webrtc_turn_message_from_caller:String="sc_webrtc_turn_message_from_caller"
    let get_message_info:String="sc_webrtc_turn_message_from_caller"
    let sc_to_delete_chat:String="sc_to_delete_chat"
    let sc_delete_chat_opponenet:String="sc_delete_chat_opponenet"
    let sc_clear_chat_opponenet:String="sc_clear_chat_opponenet"
    let userDeactivated = "userDeactivated"
    let checkUserStatus = "checkUserStatus"
    //Chat Entity Name
    let Chat_one_one:String="Chat_one_one"
    let Chat_intiated_details:String="Chat_intiated_details"
    let Mute_chats:String = "Mute_chats"
    let Contact_add:String="Contact_add"
    let User_detail:String="User_detail"
    let Favourite_Contact:String = "Favourite_Contact"
    let Link_details:String = "Link_details"
    let Contact_details:String = "Contact_details"
    let Group_details:String = "Group_details"
    let Other_Group_message:String = "Other_Group_message"
    let status_List:String = "Status_List"
    let Upload_Details:String = "Upload_Details"
    let Location_details:String = "Location_details"
    let Reply_detail:String = "Reply_detail"
    let Notification_Setting:String = "Notification_Setting"
    let Blocked_user:String = "Blocked_user"
    let Contact_Blocked_user:String = "Contact_Blocked_user"
    let Group_message_ack:String = "Group_message_ack"
    let Data_Usage_Settings:String = "Data_Usage_Settings"
    let Chat_Backup_Settings:String = "Chat_Backup_Settings"
    let Call_detail:String = "Call_detail"
    let Login_details:String = "Login_details"
    let Secret_Chat:String = "Secret_Chat"
    let Conv_detail:String="Conv_detail"
    let Status_Upload_Details:String = "Status_Upload_Details"
    let Status_one_one:String = "Status_one_one"
    let Status_initiated_details:String="Status_initiated_details"
    let Lock_Details:String="Lock_Details"
    let BaseURL:String="BaseURL"

    //Notificationname
    let Incomingmessage:String="incomingmessage"
    let typingstatus:String="Typingstatus"
    let outgoingmessage:String="outgoingmessage"
    let loaderdata:String="loaderdata"
    let statusloaderdata:String="statusloaderdata"
    let updateViewCount:String="updateViewCount"
    let loadChatView:String="loadChatView"
    let StarUpdate:String="StarUpdate"
    let user_deleted:String = "user_deleted"
    let user_cleared:String = "user_cleared"
    let incomingcall:String="incomingcall"
    let outgoingcall:String="outgoingcall"
    let incomingstatus:String="incomingstatus"
    let callStatus:String="callStatus"
    let reconnect: String = "reconnect"
    let reconnectIntimate: String = "reconnectIntimate"
    let updateCell:String="updateCell"
    let updateCallRecord = "updateCallRecord"
    let change_chat_count:String = "change_chat_count"
    let qrResponse:String = "qrResponse"
    let reloadChats:String = "reloadChats"
    let online_status_in_call = "online_status_in_call"
    let reloadData = "reload_data"
    let showNumberUpdated = "showNumberUpdated"
    let pushView = "pushView"
    let RemoveActivity = "RemoveActivity"
    let updateGroupInfo_add = "updateGroupInfo_add"
    let VoicePlayHasInterrupt = "VoicePlayHasInterrupt"
    let NoContacts = "NoContacts"
    let getPageIndex = "getPageIndex"
    let receivedTurnMessage:String="receivedTurnMessage"
    let reconnectInternet:String="reconnectInternet"
    let contactPermissionIsGiven :String = "contactPermissionIsGiven"
    
    //Error Message
    let ErrorMessage:String = "Network connection failed"
    let BecomeCelebrity:String = "Please become a connect"
    let followerEmpty:String = "Following list is empty..."
    let sugestionEmpty:String = "Suggestion list is empty..."
    let followersEmpty:String = "Follower list is empty..."
    let noPost:String = "No post yet"
    let noDataError:String = "No data avaliable"
    
    //DelayTiming
    let UploadImageDelayTime:Int = 80
    let SocketWaitDelaytime:Int = 10
    let ContactCount:Int = 10000
    let CallWaitTime:Int = 60
    let ConnectCallWaitTime:Int = 20

    //Split MultiformData
    let MultiFormDataSplitCount:Int = 7
    let VideoMultiFormDataSplitCount:Int = 30
    let UploadSize:Float = 15.0
    let DocumentUploadSize:Float = 30.0
    let SendbyteCount:Int = 30000
    let documentCompressionCount : Int = 5000000

    let photopath = Themes.sharedInstance.GetAppname() + "_photos"
    let videopathpath = Themes.sharedInstance.GetAppname() + "_video"
    let docpath = Themes.sharedInstance.GetAppname() + "_document"
    let voicepath = Themes.sharedInstance.GetAppname() + "_voice"
    let wallpaperpath = Themes.sharedInstance.GetAppname() + "_wallpaper"
    let statuspath = Themes.sharedInstance.GetAppname() + "_status"
    
    //Group Count
    let GroupCount:Int = 253
    
    var ShareText : String {
        get {
            return "Check out \(Themes.sharedInstance.GetAppname()) messenger for your smartphone. Download it today from \(BaseUrl.replacingOccurrences(of: "/api", with: ""))"
        }
    }

    let Subtext = "Check out \(Themes.sharedInstance.GetAppname()) messenger : iPhone+Android"
    
    let NavigationBarHeight_iPhoneX: CGFloat = 90
    let NavigationBarHeight: CGFloat = 70
    
    let call_free = 0;
    let call_in_ringing = 1;
    let call_in_waiting = 2;
    
    let call_status_CALLING = 0;
    let call_status_ARRIVED = 1;
    let call_status_MISSED = 2;
    let call_status_ANSWERED = 3;
    let call_status_RECEIVED = 4;
    let call_status_REJECTED = 5;
    let call_status_END = 6;
    
    //Toggle encryption
    var isEncryptionEnabled:Bool = Bool()

}


// Global Variable

var reconnecting = Bool()
var seconds = Double()
