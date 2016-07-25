//
//  AppConstant.h
//  velly
//
//  Created by m_saruwatari on 2015/02/06.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#ifndef velly_AppConstant_h
#define velly_AppConstant_h

#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define LANGUAGE    ([NSLocale preferredLanguages][0])

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define JPFONT(s) [UIFont fontWithName:@"HiraKakuProN-W3" size:s]
#define JPBFONT(s) [UIFont fontWithName:@"HiraKakuProN-W6" size:s]
#define ENFONT(s) [UIFont fontWithName:@"HelveticaNeue-Thin" size:s]

#define UIColorFromRGB(rgbValue) [UIColor \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
    blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//#define MIN(a,b)    ((a) < (b) ? (a) : (b))
//#define MAX(a,b)    ((a) > (b) ? (a) : (b))

// ------------
// api
// ------------
#define API_RESPONSE_CODE_SUCCESS [NSNumber numberWithInt:200]
#define API_RESPONSE_CODE_ERROR_TIMEOUT [NSNumber numberWithInt:0]
#define API_RESPONSE_CODE_SUCCESS_REGIST [NSNumber numberWithInt:201]
#define API_RESPONSE_CODE_ERROR_NOT_FOUND [NSNumber numberWithInt:404]
#define API_RESPONSE_CODE_ERROR_NOT_AUTH [NSNumber numberWithInt:401]
#define API_RESPONSE_CODE_ERROR_CONFLICT [NSNumber numberWithInt:409]


// api user mail or username check
#define API_CHECK_EMAIL_RESPONSE_CODE_SUCCESS [NSNumber numberWithInt:204]
#define API_CHECK_EMAIL_RESPONSE_CODE_ERROR_INVALID [NSNumber numberWithInt:400]
// api user login
#define API_USER_LOGIN_RESPONSE_CODE_ERROR_INVALID [NSNumber numberWithInt:400]
#define API_USER_LOGIN_RESPONSE_CODE_ERROR_NOTFOUND [NSNumber numberWithInt:404]

#define HOME_HEADER_NAVI_FONT JPBFONT(12.0f)

// exchange site : iroempitsu.net/zukan/tl-hexdec.htm
// ヘッダー ナビゲーション バーカラー old:E7283A    new:f2b98f
#define     HEADER_BG_COLOR       RGB(242, 185, 143)
// ヘッダー ナビゲーション アンダーバー old:E7283A   new:f2b98f
#define     HEADER_UNDER_BG_COLOR RGB(242, 185, 143)
// 通知アイコン E7283A
// ハートアイコン（いいね済の場合） FF4D4D
// ユーザ表示名 FF9226
#define     USER_DISPLAY_NAME_COLOR RGB(255, 146, 38)
// 不適切な FE4439
// それ以外のテキストリンク 0079FF
#define     OTHER_TEXT_LINK_COLOR RGB(0, 121, 255)
// 送信ボタン FFA04D
#define     INPUT_SEND_BTN_COLOR RGB(255, 160, 77)
// 送信ボタン(コメント入力前) BCBCBC
// 王冠アイコン FFD341
// ノンフォローボタン E7283A
// フォロー済みアイコン E7283A
// ソートカラー FF3246
// フォローする E7283A
// 投稿・人気順 FF3246
// 編集する 333333
#define     TEXT_EDIT_COLOR RGB(51,51,51)
// チェックアイコン FFA64D
// 保存ボタン FFA64D
#define     BTN_SAVE_COLOR RGB(255, 166, 77)

// ログアウト E7283A
// オンオフスイッチ FFA64D
// チェックアイコン FFA64D
// 投稿する FFA64D

// 新規登録時の紹介ページテキストカラー AAAAAA
#define     TXT_REGIST_INTRO_COLOR RGB(170, 170, 170)

#define     COMMON_DEF_GRAY_COLOR RGB(235,235,235)



//#define     URL_SCHEMA            @"me.myrecoup"
#define     URL_SCHEMA            @"jp.co.bondy.myrecoup"

#define     TW_CALLBACK_URL       @"jp.co.bondy.myrecoup://twitter_access_tokens/"

#define kTabBarHeight 48

// 参考 
// http://d.hatena.ne.jp/k2_k_hei/20120511/1336750473
// ------------------------------
// DEBUG
// ------------------------------
#ifdef DEBUG

#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define     OAUTH_TW_API_KEY      @"Zwao2sSt2zNNunrFtotgzLCJ5"                              // 7CsmVJgeJhE93dGD5cod11vIx
#define     OAUTH_TW_API_SECRET   @"E2bvKX5uKUgthECAC4ROhC8H0k21su1tGdlQTgOGQBazOhmH1M"     // dhoThvOFHQbJwLrPmkCZQptt9LcZ8F5Sh3XiRHkswvq9qvLpBY

#define     OAUTH_FB_APP_ID      @"809667622419611" // 604516616337449

#define     SEND_BIRD_APP_ID  @"C54F7BAA-6053-4110-AC1E-41726A035ED8"

#define     SEND_BIRD_API_TOKEN @"c865518d7fde2bff12dbfbef393e55cb935e90a1"

#define     SEND_BIRD_CHANNEL_URL  @"9f522.development"

#define     REPRO_TOKEN @"8b88892e-f3f0-4501-95df-50afe44777ae"


#else
// ------------------------------
// PRODUCTION
// ------------------------------

#define DLog(...)

#define     OAUTH_TW_API_KEY      @"Zwao2sSt2zNNunrFtotgzLCJ5"                              // Zwao2sSt2zNNunrFtotgzLCJ5
#define     OAUTH_TW_API_SECRET   @"E2bvKX5uKUgthECAC4ROhC8H0k21su1tGdlQTgOGQBazOhmH1M"     // E2bvKX5uKUgthECAC4ROhC8H0k21su1tGdlQTgOGQBazOhmH1M

#define     OAUTH_FB_APP_ID      @"809667622419611" // 809667622419611

#define     SEND_BIRD_APP_ID  @"36D15566-5F12-446B-A451-36A343D1C3E6"

#define     SEND_BIRD_API_TOKEN @"58e98aa92826e125e9e2446f143a8f6091c12fa9"

#define     SEND_BIRD_CHANNEL_URL  @"47c7c.production"

#define     REPRO_TOKEN @"3133226a-1f7c-4e11-b9d1-ada38a99f01e"
#endif

// ALog always displays output regardless of the DEBUG alarm
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


typedef enum : NSInteger{
    VLISACTIVENON = 0,
    VLISACTIVEDOIT = 1,
}VLISACTIVE;

typedef enum : int{
    VLISBOOLFALSE = 0,
    VLISBOOLTRUE = 1,
}VLISBOOL;

typedef enum : NSInteger{
    VLHOMESORTPOP = 0,
    VLHOMESORTNEW = 1,
    VLHOMELIKE = 2,
}VLHOMESORT;

typedef enum : NSInteger{
    INFOTYPENEWS = 0,
    INFOTYPEINFO = 1,
}INFOTYPE;

typedef enum : NSInteger{
    VLRANKINGSORTPRO = 0,
    VLRANKINGSORTNORMAL = 1,
}VLRANKINGSORT;

typedef enum : NSInteger{
    VLPOSTLIKENO = 0,
    VLPOSTLIKEYES = 1,
}VLPOSTLIKE;

typedef enum : NSInteger{
    VLINFOTYPEFOLLOWED,
    VLINFOTYPERANKUP,
    VLINFOTYPELIKED,
    VLINFOTYPECOMMENTED,
    VLINFOTYPEOFFICIALNEWS,
    VLINFOTYPEOFFICIALIMPORTANTNEWS,
}VLINFOTYPE;

typedef enum : NSInteger{
    VLModelNameIPhone4  = 40,
    VLModelNameIPhone5  = 50,
    VLModelNameIPhone6  = 60,
    VLModelNameIPhone6p = 61,
    VLModelNameIPad     = 10000,
}VLModelName;

typedef enum : NSInteger{
    VLUSERATTRPRO = 0,
    VLUSERATTRGENERAL = 1,
}VLUSERATTR;


#pragma mark Repro var
typedef NS_ENUM(NSUInteger, REPROEVENT) {
    OPENMESSAGELIST           = 0,
    OPENMESSAGE               = 1,
    TAGTAP                    = 2,
    POSTSUBMIT                = 3,
    MOVIESUBMIT               = 4,
    FOLLOWTAP                 = 5,
    GOODTAP                   = 6,
    SEARCHBUTTONTAP           = 7,
    LOGIN                     = 8,
    SIGNUP                    = 9,
    LOGOUT                    = 10,
    HOMESORT                  = 11,
    RANKINGSORT               = 12,
    INFOSORT                  = 13,
    COMMENTTAP                = 14,
    POSTBUTTONTAP             = 15,
    POSTBUTTON_TAKEAPICTAP    = 16,
    POSTBUTTON_LIBRARYTAP     = 17,
    POSTBUTTON_MOVIETAP       = 18,
    TOOKAPHOTO                = 19,
    SELECTEDFROMLIBRARY       = 20,
    EFFECTSUBMITTAP           = 21,
    TOOKAMOVIE                = 22,
    CUTMOVIE                  = 23,
    THUMBNAILEDITED           = 24,
    OPENDETAIL                = 25,
    OPENPROFILE               = 26,
    OPENHOME                  = 27,
    OPENRANKING               = 28,
    OPENINFO                  = 29,
    OPENMYPAGE                = 30,
    OPENMYRECO                = 31,
};

typedef NS_ENUM(NSUInteger, REPROEVENTPROP) {
    USER_PID   = 0,
    SENDER     = 1,
    RECEIVER   = 2,
    TAG        = 3,
    WORD       = 4,
    CATEGORY   = 5,
    VIEW       = 6,
    TARGET     = 7,
    TYPE       = 8,
    POST       = 9,
    TAPPED     = 10,
};

typedef NS_ENUM(NSUInteger, REPROEVENTITEM) {
    IMG        = 0,
    NAME       = 1,
};

typedef NS_ENUM(NSUInteger, GOODACTIONTYPE) {
    SMALLHEART     = 0,
    BIGHEART       = 1,
    IMGDOUBLETAP   = 2,
    HEART_DETAIL   = 3,
};

typedef NS_ENUM(NSUInteger, LOGINTYPE) {
    EMAIL      = 0,
    TWITTER    = 1,
    FACEBOOK   = 2,
};

typedef NS_ENUM(NSUInteger, POSTSELECTTYPE) {
    TAKEAPHOTO   = 0,
    LIBRARY      = 1,
};

/*
 Production Twitter
 Consumer Key	Zwao2sSt2zNNunrFtotgzLCJ5
 Consumer Secret	E2bvKX5uKUgthECAC4ROhC8H0k21su1tGdlQTgOGQBazOhmH1M
 
 Production Facebook
 FacebookAppID : 809667622419611
 FacebookDisplayName : Velly
 
 Dev
 Consumer Key	7CsmVJgeJhE93dGD5cod11vIx
 Consumer Secret	dhoThvOFHQbJwLrPmkCZQptt9LcZ8F5Sh3XiRHkswvq9qvLpBY
 FacebookAppID : 604516616337449
 FacebookDisplayName : flasco_pico
 
*/

#endif
