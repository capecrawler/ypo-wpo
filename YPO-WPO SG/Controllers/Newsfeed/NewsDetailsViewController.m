//
//  NewsViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NewsDetailsViewController.h"
#import "CommentsViewController.h"
#import "YPOArticle.h"
#import "NSDate+FormattedString.h"

@interface NewsDetailsViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIView *commentsView;
@property (nonatomic, strong) NSString *urlRequestString;
@end

@implementation NewsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.articleTitle;
    self.commentCountLabel.text = @"";
    
    [self.webView loadRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:self.urlRequestString]]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id controller = [segue destinationViewController];
    if ([controller isKindOfClass:[CommentsViewController class]]) {
        CommentsViewController *newsDetailsController = (CommentsViewController *)controller;
        newsDetailsController.articleID = self.articleID;
    }
}


#pragma mark - UIWebViewDelegate

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *redirectString = [NSString stringWithFormat:@"%@#", self.urlRequestString];
    if ([redirectString isEqualToString:request.URL.absoluteString]) {
        [self performSegueWithIdentifier:@"CommentsViewController" sender:self];
        return NO;
    }
    return YES;
}


#pragma mark - Properties

- (NSString *)urlRequestString {
    if (_urlRequestString == nil) {
        _urlRequestString = [NSString stringWithFormat:@"http://www.ypowposg.org/webview/?id=%ld", (long) self.articleID];
    }
    return _urlRequestString;
}

@end
