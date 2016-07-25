//
//  RssNewsTableViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2015/12/17.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RssNewsTableViewCell.h"

static const NSUInteger margin = 2.5;

@implementation RssNewsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configureCell];
    }
    return self;
}

- (void)configureCell
{
    //セルのイメージ
    //|-------cell--------------------------
    //|2.5 ______newsInfoView____________  |
    //| |10_____                        |  |
    //| | |     |                       |  |
    //| | |     |                       |  |
    //| | |_____|                       |  |
    //| |_______________________________|  |
    //|                                    |
    //--------------------------------------
    
    //ここでCell設定
    self.backgroundColor = [UIColor whiteColor];
    if ([self respondsToSelector:@selector(layoutMargins)]) {
        self.layoutMargins = UIEdgeInsetsZero;
    }
    self.clipsToBounds = YES;//frameサイズ外を描画しない
    
    //記事画像
    [self.newsInfoView addSubview:self.newsThumbView];
    
    //記事タイトル
    [self.newsInfoView addSubview:self.newsTitleLabel];
    
    //記事カテゴリー
    [self.newsInfoView addSubview:self.newsCategoryLabel];
    [self.contentView addSubview:self.newsInfoView];
    
    //続きを読む
    [self.contentView addSubview:self.readMoreLabel];
    
    //imobile SDK
    [self.imobileSDKView addSubview:self.imobileSDKImageView];
    [self.imobileSDKView addSubview:self.imobileSDKTitleLabel];
    [self.contentView addSubview:self.imobileSDKView];
    
    [self.contentView addSubview:self.separatorView];
    
    [self.contentView addSubview:self.neaView];
}

///記事ベース
- (UIView *)newsInfoView {
    if (!_newsInfoView) {
        _newsInfoView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_newsInfoView setBackgroundColor:[UIColor whiteColor]];
    }
    return _newsInfoView;
}

///記事画像
- (UIImageView *)newsThumbView {
    if (!_newsThumbView) {
        _newsThumbView  = [[UIImageView alloc] initWithFrame:CGRectMake(margin*4, margin*4, 70, 70)];
        [_newsThumbView.layer setCornerRadius:3];
        [_newsThumbView setClipsToBounds:YES];
    }
    return _newsThumbView;
}

///記事タイトル
- (UILabel *)newsTitleLabel {
    if (!_newsTitleLabel) {
        _newsTitleLabel = [[UILabel alloc] init];
        _newsTitleLabel.numberOfLines = 0;
        _newsTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _newsTitleLabel.font = JPFONT(13.5);
        _newsTitleLabel.textColor = [UIColor colorWithRed:0.42 green:0.40 blue:0.36 alpha:1.0];
    }
    return _newsTitleLabel;
}

///記事カテゴリー
- (UILabel *)newsCategoryLabel {
    if (!_newsCategoryLabel) {
        _newsCategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_newsCategoryLabel setNumberOfLines:1];
        [_newsCategoryLabel setFont:JPFONT(11)];
        [_newsCategoryLabel setTextColor:[UIColor colorWithRed:0.42 green:0.40 blue:0.36 alpha:0.6]];
    }
    return _newsCategoryLabel;
}

///続きを読むラベル
- (UILabel *)readMoreLabel {
    if (!_readMoreLabel) {
        _readMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_readMoreLabel setNumberOfLines:1];
        [_readMoreLabel setTextColor:[UIColor colorWithRed:1.00 green:0.42 blue:0.00 alpha:1.0]];
        [_readMoreLabel setFont:JPFONT(14)];
        [_readMoreLabel setText:@"続きを読む"];
        [_readMoreLabel setTextAlignment:NSTextAlignmentCenter];
        [_readMoreLabel setHidden:YES];
    }
    return _readMoreLabel;
}

///imobile ベース
- (UIView *)imobileSDKView {
    if (!_imobileSDKView) {
        _imobileSDKView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_imobileSDKView setBackgroundColor:[UIColor whiteColor]];
        [_imobileSDKView setHidden:YES];
    }
    return _imobileSDKView;
}

///imobile画像
- (UIImageView *)imobileSDKImageView {
    if (!_imobileSDKImageView) {
        _imobileSDKImageView = [[UIImageView alloc]
                                initWithFrame:CGRectMake(margin*4, margin*4, 70, 70)];
        [_imobileSDKImageView.layer setCornerRadius:3];
        [_imobileSDKImageView setClipsToBounds:YES];
    }
    return _imobileSDKImageView;
}

///imobileタイトル
- (UILabel *)imobileSDKTitleLabel {
    if (!_imobileSDKTitleLabel) {
        _imobileSDKTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_imobileSDKTitleLabel setNumberOfLines:0];
        [_imobileSDKTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_imobileSDKTitleLabel setFont:JPFONT(13.5)];
        [_imobileSDKTitleLabel setTextColor:[UIColor colorWithRed:0.42 green:0.40 blue:0.36 alpha:1.0]];
    }
    return _imobileSDKTitleLabel;
}

///AdMobの広告を作成
- (GADNativeExpressAdView *)neaView {
    if (!_neaView) {
        _neaView = [[GADNativeExpressAdView alloc]
                    initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(admobHeight)];
        [_neaView setFrame:CGRectMake(0, 5, _neaView.bounds.size.width, _neaView.bounds.size.height)];
        [_neaView setAdUnitID:admobUnitId];
        [_neaView setHidden:YES];
    }
    return _neaView;
}

///仕切り線
- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_separatorView.layer
         setBorderColor:[UIColor colorWithRed:0.42 green:0.40 blue:0.36 alpha:0.35].CGColor];
        [_separatorView.layer setBorderWidth:0.5];
        [_separatorView setHidden:NO];
    }
    return _separatorView;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
