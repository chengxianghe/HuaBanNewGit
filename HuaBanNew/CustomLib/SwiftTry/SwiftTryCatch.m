
#import "SwiftTryCatch.h"

@implementation SwiftTryCatch

/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */
+ (void)swtry:(EXP)try swcatch:(EXCEP)catch swfinally:(EXP)finally {
    
    @try {
        try ? try() : nil;
    }
    
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    
    @finally {
        finally ? finally() : nil;
    }
}

+ (void)throwString:(NSString*)s
{
	@throw [NSException exceptionWithName:s reason:s userInfo:nil];
}

+ (void)throwException:(NSException*)e
{
	@throw e;
}

@end
