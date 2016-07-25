//
//  UIPlaceHolderTextView.m
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "UIPlaceHolderTextView.h"

@interface UIPlaceHolderTextView()
{
    UITextView *_textView;
    BOOL _disabled;
    BOOL _enabled;
}

@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) CGSize keyboardSize;

@property (nonatomic, setter = setToolbarCommand:) BOOL isToolBarCommand;
@property (nonatomic, setter = setDoneCommand:) BOOL isDoneCommand;

@property (nonatomic , strong) UIBarButtonItem *previousBarButton;
@property (nonatomic , strong) UIBarButtonItem *nextBarButton;

@property (nonatomic, retain) UILabel *placeHolderLabel;

@property (weak) id keyboardDidShowNotificationObserver;
@property (weak) id keyboardWillHideNotificationObserver;

@end

@implementation UIPlaceHolderTextView

@synthesize required;
@synthesize toolbar;
@synthesize scrollView;
@synthesize keyboardIsShown;
@synthesize keyboardSize;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if __has_feature(objc_arc)
#else
    [_placeHolderLabel release]; _placeHolderLabel = nil;
    [_placeholderColor release]; _placeholderColor = nil;
    [_placeholder release]; _placeholder = nil;
    [super dealloc];
#endif
}

-(void)setUpKeyBoard{
    
    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.window.frame.size.width, 44);
    // set style
    [toolbar setBarStyle:UIBarStyleDefault];
    
    //    self.previousBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Previous", @"Previous") style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonIsClicked:)];
    //    self.nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next") style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonIsClicked:)];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonIsClicked:)];
    //NSArray *barButtonItems = @[self.previousBarButton, self.nextBarButton, flexBarButton, doneBarButton];
    NSArray *barButtonItems = @[flexBarButton, doneBarButton];
    
    toolbar.items = barButtonItems;
    [self setInputAccessoryView:toolbar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];

    

}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpKeyBoard];
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void) doneButtonIsClicked:(id)sender{
    [self setDoneCommand:YES];
    [self resignFirstResponder];
    [self setToolbarCommand:YES];
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeHolderLabel == nil )
        {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.bounds.size.width - 16,0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}


- (void)scrollToField
{
    CGRect textViewRect = [[_textView superview] convertRect:_textView.frame toView:self.window];
    CGRect aRect = self.window.bounds;
    
    aRect.origin.y = -scrollView.contentOffset.y;
    aRect.size.height -= keyboardSize.height + self.toolbar.frame.size.height + 22;
    
    CGPoint textRectBoundary = CGPointMake(textViewRect.origin.x, textViewRect.origin.y + textViewRect.size.height);
    
    if (!CGRectContainsPoint(aRect, textRectBoundary) || scrollView.contentOffset.y > 0) {
        CGPoint scrollPoint = CGPointMake(0.0, self.superview.frame.origin.y + _textView.frame.origin.y + _textView.frame.size.height - aRect.size.height);
        
        if (scrollPoint.y < 0) scrollPoint.y = 0;
        
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (BOOL) validate{
    _isValid = YES;
    
    if (required && [self.text isEqualToString:@""]){
        _isValid = NO;
    }
    return _isValid;
}

- (void)setNeedsAppearance:(id)sender
{
    //UIPlaceHolderTextView *textView = (UIPlaceHolderTextView*)sender;
    
//    if (![textView i])
//        [self setBackgroundColor:[UIColor lightGrayColor]];
//    //else if (![textField isValid])
//    //    [self setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:0.5]];
//    else
//        [self setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - UIKeyboard notifications

- (void) keyboardDidShow:(NSNotification *) notification{
    if (_textView== nil) return;
    if (keyboardIsShown) return;
    if (![_textView isKindOfClass:[UITextView class]]) return;
    
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardSize = [aValue CGRectValue].size;
    
    [self scrollToField];
    
    self.keyboardIsShown = YES;
}

- (void) keyboardWillHide:(NSNotification *) notification{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (_isDoneCommand){
            [self.scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:NO];
        }
    }];
    
    keyboardIsShown = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardDidShowNotificationObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardWillHideNotificationObserver];
}

#pragma mark - UITextField notifications

- (void)textViewDidBeginEditing:(NSNotification *) notification{
    UITextView *textView = (UITextView*)[notification object];
    
    _textView = textView;
    
    [self setKeyboardDidShowNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardDidShow:notification];
    }]];
    
    [self setKeyboardWillHideNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardWillHide:notification];
    }]];
    
    //[self setBarButtonNeedsDisplayAtTag:textView.tag];
    
    if ([self.superview isKindOfClass:[UIScrollView class]] && self.scrollView == nil){
        self.scrollView = (UIScrollView*)self.superview;
    }
    
    //[self selectInputView:textView];
    [self setInputAccessoryView:toolbar];
    
    [self setToolbarCommand:NO];
}

- (void)textViewDidEndEditing:(NSNotification *) notification{
//    UITextView *textView = (UITextView*)[notification object];
    
//    if ((_isDateField || _isTimeField) && [textField.text isEqualToString:@""] && _isDoneCommand){
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        
//        if (self.dateFormat) {
//            [dateFormatter setDateFormat:self.dateFormat];
//        } else {
//            [dateFormatter setDateFormat:@"MM/dd/YY"];
//        }
//        
//        [textField setText:[dateFormatter stringFromDate:[NSDate date]]];
//    }
    
    [self validate];
    
    [self setDoneCommand:NO];
    
    _textView = nil;
}

@end
