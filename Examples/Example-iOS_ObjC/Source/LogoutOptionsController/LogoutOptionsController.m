//
//  LogoutOptionsController.m
//  Example-iOS_ObjC
//
//  Created by Michael Moore on 11/15/22.
//  Copyright © 2022 William Denniss. All rights reserved.
//

#import "LogoutOptionsController.h"

static NSArray<LogoutOption>* kLogoutOptions;

@interface LogoutOptionsController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation LogoutOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];

    _logoutOptionsSelected = [[NSMutableArray alloc] init];
}

+ (instancetype)controllerWithLogoutOptions:(NSArray<LogoutOption>*)logoutOptions {
    NSAssert(logoutOptions.count > 0, @"Must provide at least 1 option");

    kLogoutOptions = [[NSArray alloc] initWithArray:logoutOptions];

    return [[self alloc] initLogoutOptionsController];
}

- (instancetype)initLogoutOptionsController {

    self = [super init];

    if (self) {
        NSInteger rowHeight = 44.0;
        CGRect rect = CGRectMake(0, 0, 272, rowHeight * kLogoutOptions.count);
        [self setPreferredContentSize:rect.size];

        UITableView *alertTableView  = [[UITableView alloc] initWithFrame:rect];
        alertTableView.delegate = self;
        alertTableView.dataSource = self;
        alertTableView.estimatedRowHeight = rowHeight;
        alertTableView.rowHeight = UITableViewAutomaticDimension;
        alertTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

        [alertTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [alertTableView setUserInteractionEnabled:YES];
        [alertTableView setScrollEnabled:NO];
        [alertTableView setEditing:YES animated:YES];
        [alertTableView setAllowsMultipleSelectionDuringEditing:YES];
        [alertTableView setAllowsSelection:YES];

        [self.view addSubview:alertTableView];
        [self.view bringSubviewToFront:alertTableView];
        [self.view setUserInteractionEnabled:YES];
    }

    return self;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"logoutCell" ;

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }

    [cell.textLabel setText:kLogoutOptions[indexPath.row]];

    return  cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kLogoutOptions.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LogoutOption selectedOption = kLogoutOptions[indexPath.row];

    if (![_logoutOptionsSelected containsObject:selectedOption]) {
        [_logoutOptionsSelected addObject:selectedOption];
    } else {
        [_logoutOptionsSelected removeObject:selectedOption];
    }
}

@end
