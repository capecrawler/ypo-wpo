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

@interface NewsDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIView *commentsView;
@end

@implementation NewsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.article.title;
    self.commentCountLabel.text = @"";
    
    NSString *html = [self constructHTML:self.article.title content:self.article.content];
    [self.webView loadHTMLString:html baseURL:nil];
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
        newsDetailsController.article = self.article;
    }
}


- (NSString *)constructHTML:(NSString *)title content:(NSString *)content{
    NSMutableString *html = [[NSMutableString alloc] init];
    [html appendFormat:@"<html><head><title>%@</title>", title];
    [html appendString:@"<style>\
                 @import url(http://fonts.googleapis.com/css?family=Roboto:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800);\
                 body {\
                 margin:20px 20px 80px 20px;\
                     font-family: 'Roboto', 'helvetica neue', helvetica, sans-serif;\
                     line-height: 1.6em;\
                     font-size: 13pt;\
                 }\
                 h1 {\
                     font-size:130%;\
                     line-height: 1.3em;\
                 }\
                 p {\
                 }\
                 span {\
                 color: #666;\
                 }\
                 span.date-posted {\
                     font-size: 80%;\
                 \
                 div img {\
                     max-width:100%;\
                 height:auto;\
                 }\
                 #article {\
                 border-top: 1px solid #666;\
                 margin-top: 20px;\
                 padding-top: 5px;\
                 }\
                 #article div i {\
                 color: #666;\
                 font-style: italic;\
                 }\
                 iframe {\
                 width:100%;\
                 }\
                 </style></head>"];
    [html appendString:@"<body>"];
    [html appendString:content];
    [html appendString:@"</body></html>"];
    return html;
}

@end
