//
//  Defines.m
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/08/25.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import "Defines.h"

@implementation Defines

const int DEFINES_MAX_TIME  = 30;

///Reproのイベント名
NSString * const DEFINES_REPROEVENTNAME[] = {
    [OPENMESSAGELIST]           = @"Open Message List",
    [OPENMESSAGE]               = @"Open Message",
    [TAGTAP]                    = @"Tag Tap",
    [POSTSUBMIT]                = @"Post Submit",
    [MOVIESUBMIT]               = @"Movie Submit",
    [FOLLOWTAP]                 = @"Follow Tap",
    [GOODTAP]                   = @"Good Tap",
    [SEARCHBUTTONTAP]           = @"Search Button Tap",
    [LOGIN]                     = @"Login",
    [SIGNUP]                    = @"SignUp",
    [LOGOUT]                    = @"Logout",
    [HOMESORT]                  = @"Home Sort",
    [RANKINGSORT]               = @"Ranking Sort",
    [INFOSORT]                  = @"Info Sort",
    [COMMENTTAP]                = @"Comment Tap",
    [POSTBUTTONTAP]             = @"Post Button Tap",
    [POSTBUTTON_TAKEAPICTAP]    = @"Take a Picure Tap",
    [POSTBUTTON_LIBRARYTAP]     = @"From Library Tap",
    [POSTBUTTON_MOVIETAP]       = @"Take a Movie Tap",
    [TOOKAPHOTO]                = @"Took Photo",
    [SELECTEDFROMLIBRARY]       = @"Selected From Library",
    [EFFECTSUBMITTAP]           = @"Post Effect Submit",
    [TOOKAMOVIE]                = @"Took a Movie",
    [CUTMOVIE]                  = @"Movie Cut Completed",
    [THUMBNAILEDITED]           = @"Movie Thumbnail Edited",
    [OPENDETAIL]                = @"Move to Detail",
    [OPENPROFILE]               = @"Move to Profile",
    [OPENHOME]                  = @"Move to Home",
    [OPENRANKING]               = @"Move to Ranking",
    [OPENINFO]                  = @"Move to Info",
    [OPENMYPAGE]                = @"Move to Mypage",
    [OPENMYRECO]                = @"Move to MyReco",
};

///Reproのイベントのパラメータ名
NSString * const DEFINES_REPROEVENTPROPNAME[] = {
    [USER_PID]     = @"user_pid",
    [SENDER]       = @"sender",
    [RECEIVER]     = @"receiver",
    [TAG]          = @"tag",
    [WORD]         = @"word",
    [CATEGORY]     = @"category",
    [VIEW]         = @"view",
    [TARGET]       = @"target",
    [TYPE]         = @"type",
    [POST]         = @"post",
    [TAPPED]       = @"tapped",
};

///Reproのイベントのパラメータ値
NSString * const DEFINES_REPROEVENTPROPITEM[] = {
    [IMG]          = @"img",
    [NAME]         = @"name",
};
@end
