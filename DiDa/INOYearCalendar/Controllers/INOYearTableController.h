//
// Copyright 2014 Inostudio Solutions
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface INOYearTableController : UIViewController {
    __weak IBOutlet UITableView *searchTableView;
    __weak IBOutlet UITableView *yearTableView;
    __weak IBOutlet UIView *bottomView;
    NSInteger tagSelected;
    NSIndexPath *nowIndexPath;
    __weak IBOutlet UISearchBar *memoSearchBar;
    AppDelegate *appDelegate;
    NSIndexPath *selectedIndexPath;
    AVAudioPlayer *audioPlayer;
    NSString *filePathString;
    NSString *shareText;
    NSString *shareURL;
    
    NSInteger numberOfSharedItems;
}

@end
