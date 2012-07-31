//
//  TableViewController.h
//  XMLParseProgress
//
//  Created by 達郎 植田 on 12/07/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController
{
    UIProgressView  *_progressView;
}

@property (strong) NSArray *itemsArray;

- (IBAction)refresh:(id)sender;
@end
