//
//  NSDate+LXExtension.h
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (LXExtension)

- (BOOL)lx_isThisMinute;
- (BOOL)lx_isThisHour;
- (BOOL)lx_isYesterday;
- (BOOL)lx_isToday;
- (BOOL)lx_isTomorrow;
- (BOOL)lx_isThisYear;
- (BOOL)lx_isWeekend;

- (BOOL)lx_isSameDayAsDate:(NSDate *)date;

- (NSInteger)lx_yearsToNow;

/// 获取对应的 dispatch_time_t 值
- (dispatch_time_t)lx_dispatchTime;

@end

NS_ASSUME_NONNULL_END
