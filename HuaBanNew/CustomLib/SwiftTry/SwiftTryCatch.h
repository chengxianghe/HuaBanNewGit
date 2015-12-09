
#import <Foundation/Foundation.h>

@import UIKit;

typedef void(^EXP)();
typedef void(^EXCEP)(NSException* exception);

@interface SwiftTryCatch : NSObject


/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */
+ (void)swtry:(EXP)try swcatch:(EXCEP)catch swfinally:(EXP)finally;
+ (void)throwString:(NSString*)s;
+ (void)throwException:(NSException*)e;
@end
