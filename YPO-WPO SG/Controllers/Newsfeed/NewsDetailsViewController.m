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
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:html baseURL:baseURL];
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
    [html appendString:@"<meta name=\"description\" content=\"\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"];
    [html appendString:@"<link rel=\"stylesheet\" href=\"css/normalize.css\">"];
    [html appendString:@"<link rel=\"stylesheet\" href=\"css/main.css\">"];
    [html appendString:@"<link rel=\"stylesheet\" href=\"css/article.css\">"];
    [html appendString:@"<body>"];
    [html appendString:@"<article>"];
    [html appendString:@"<header>"];
    [html appendFormat:@"<div class=\"banner\"><img src=\"%@\"></div>", self.article.imageURL];
    [html appendFormat:@"<h1>%@</h1>",self.article.title];
    [html appendFormat:@"<p style=\"color:#999;\">%@ | %@</p>", [self.article.postDate stringWithFormat:@"EEEE, dd MMMM yyyy"], self.article.author];
    [html appendString:@"</header>"];
    [html appendString:content];
    [html appendString:@"</article>"];
    [html appendString:@"</body></html>"];
    return html;
}

@end
