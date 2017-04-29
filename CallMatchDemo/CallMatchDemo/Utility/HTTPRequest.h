#define DEFAULT_REQUEST_TIME_OUT 10.0

#import <Foundation/Foundation.h>

@interface HTTPRequest : NSObject


//-------------- Post methods ------------------
#pragma mark - Post method declarations

// Convenient post method with success & failure handler
+(void) post:(nonnull NSString*) url data:(nullable NSDictionary*) data
                            success:(nullable void (^)(NSDictionary<NSString*, id> * _Nullable response))successHandler
                            failure:(nullable void (^)(NSError * _Nonnull err))failureHandler;

// Convenient post method with success, failure handler and additional headers
+(void) post:(nonnull NSString*) url data:(nullable NSDictionary*) data
                            addHeaders:(nullable NSDictionary *) headers
                            success:(nullable void (^)(NSDictionary<NSString*, id> * _Nullable response))successHandler
                            failure:(nullable void (^)(NSError * _Nonnull err))failureHandler;

//-------------- Get methods ------------------
#pragma mark - Get method declarations

+(void) get:(nonnull NSString*) url
                                success:(nullable void (^)(NSDictionary<NSString*, id> * _Nullable response))successHandler
                                failure:(nullable void (^)(NSError * _Nonnull err))failureHandler;

+(void) get:(nonnull NSString*) url
                                addHeaders:(nullable NSDictionary *) headers
                                success:(nullable void (^)(NSDictionary<NSString*, id> * _Nullable response))successHandler
                                failure:(nullable void (^)(NSError * _Nonnull err))failureHandler;

+(void) getRawData:(NSString* _Nonnull) url addHeaders:(NSDictionary* _Nullable) headers
         success:(nullable void (^)(NSData * _Nonnull))successHandler
         failure:(nullable void (^)(NSError * _Nonnull))failureHandler;
@end
