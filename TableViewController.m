//
//  TableViewController.m
//  XMLParseProgress
//
//  Created by 達郎 植田 on 12/07/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"
#import "RSSParser.h"
#import "RSSEntry.h"
#import "UIImageView+AFNetworking.h"

const NSString *kStringURLHatebu = 
@"http://pipes.yahoo.com/pipes/pipe.run?_id=9c1e3c39f4e2e5af59164db181479929&_render=rss&tag=";

@interface TableViewController ()

@end

@implementation TableViewController
@synthesize itemsArray = _itemsArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// リストテーブルのアイテム数を返すメソッド
// 「UITableViewDataSource」プロトコルの必須メソッド
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsArray.count;
}

// リストテーブルに表示するセルを返すメソッド
// 「UITableViewDataSource」プロトコルの必須メソッド
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    // 範囲チェックを行う
    if (indexPath.row < self.itemsArray.count) {
        
        // セルを作成する
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        NSURL *urlOgImage = [[self.itemsArray objectAtIndex:indexPath.row] urlOgImage];
        if (urlOgImage != nil) {
            [cell.imageView setImageWithURL:urlOgImage
                             placeholderImage:[UIImage imageNamed:@"loading3.gif"]];
        }
        else {
            UIImage *noImage = [UIImage imageNamed:@"noImage.png"];
            cell.imageView.image = noImage;
        }
                
        cell.textLabel.text = [[NSString alloc] initWithString:
                       [[self.itemsArray objectAtIndex:indexPath.row] title]];
        cell.detailTextLabel.text = [[NSString alloc] initWithString:
                       [[self.itemsArray objectAtIndex:indexPath.row] text]];
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)refresh:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"読み込んでいます"
                                                        message:@"\n\n"
                                                       delegate:self
                                              cancelButtonTitle:@"キャンセル"
                                              otherButtonTitles:nil];
    _progressView = [[UIProgressView alloc]
                     initWithFrame:CGRectMake(30.0f, 60.0f, 225.0f, 90.0f)];
    [alertView addSubview:_progressView];
    [_progressView setProgressViewStyle: UIProgressViewStyleBar];
    [alertView show];
    
    // 別スレッドを立てる
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        
        // RSSファイルのURLをつくる
        NSString *escapedUrlString = 
        [@"これはすごい" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *myPipeURLString = 
        [NSString stringWithFormat:@"%@%@", kStringURLHatebu, escapedUrlString];
        
        // urlArrayをつくる
        NSArray *urls = [NSArray arrayWithObject:myPipeURLString];
        NSMutableArray *urlArray = [NSMutableArray array];
        for (NSString *str in urls) {
            NSURL *url = [NSURL URLWithString:str];
            if (url) {
                [urlArray addObject:url];
            }
        }
        
        // RSSファイルを読み込む
        [self reloadFromContentsOfURLsFromArray:urlArray];
        NSLog(@"reloaded from contents of URLs");
        
        // メインスレッドに戻す
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            
            // テーブル更新
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self.tableView reloadData];
        }];
    }];
}

// URLの配列を受け取り、「_listItemsArray」の内容を設定するメソッド
// 配列の各要素は「NSURL」クラスのインスタンスとする
- (void)reloadFromContentsOfURLsFromArray:(NSArray *)urlsArray
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSURL *url in urlsArray) {
        @autoreleasepool {
            
            // URLから読み込む
            NSArray *itemsArray = [self itemsArrayFromContentsOfURL:url];
            
            // 配列に追加する
            [newArray addObjectsFromArray:itemsArray];
        }
    }
    
    // データメンバーに設定する
    self.itemsArray = newArray;
}

// URLからファイルを読み込み、アイテムの配列を返すメソッド
- (NSArray *)itemsArrayFromContentsOfURL:(NSURL *)url
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    RSSParser *parser = [[RSSParser alloc] init];
    
    // URLから読み込む
    if ([parser parseContentsOfURL:url progressView:_progressView]) {
        
        // 記事を読み込む
        [newArray addObjectsFromArray:[parser entries]];
    }
    return newArray;
}

@end
