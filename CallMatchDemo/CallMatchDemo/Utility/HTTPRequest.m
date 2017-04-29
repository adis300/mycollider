#import "HTTPRequest.h"

@implementation HTTPRequest

// ---------------------- Implement post methods -----------------------------
#pragma mark - Post method implementations

+(void) post:(NSString*) url data:(NSDictionary*) data
                        success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                        failure:(void (^)(NSError *))failureHandler{
    return [HTTPRequest post:url data: data addHeaders:nil success:successHandler failure:failureHandler completionQueue: nil delegate:nil timeout: 0];
}

+(void) post:(NSString*) url data:(NSDictionary*) data
                        addHeaders:(NSDictionary*) headers
                        success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                        failure:(void (^)(NSError *))failureHandler{
    return [HTTPRequest post:url data: data addHeaders:headers success:successHandler failure:failureHandler completionQueue: nil delegate: nil timeout: 0];
}

+(void) post:(NSString*) url data:(NSDictionary*) data
                        addHeaders:(NSDictionary*) headers
                        success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                        failure:(void (^)(NSError *))failureHandler
                        completionQueue: (dispatch_queue_t) completionQueue
                        delegate: (id) delegate
                        timeout: (NSTimeInterval) timeout{
    return [HTTPRequest sendHttp:url data:data method:@"POST" addHeaders:headers success:successHandler failure:failureHandler completionQueue:completionQueue delegate:delegate timeout:timeout];
}

// ---------------------- Implement get methods -----------------------------
#pragma mark - Get method implementations

+(void) get:(NSString*) url
                        success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                        failure:(void (^)(NSError *))failureHandler {
    return [HTTPRequest get:url addHeaders:nil success:successHandler failure:failureHandler completionQueue: nil delegate:nil timeout: 0];
}

+(void) get:(NSString*) url
                        addHeaders:(NSDictionary*) headers
                        success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                        failure:(void (^)(NSError *))failureHandler{
    return [HTTPRequest get:url addHeaders:headers success:successHandler failure:failureHandler  completionQueue: nil delegate: nil timeout: 0];
}

+(void) get:(NSString*) url
                        addHeaders:(NSDictionary*) headers
                        success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                        failure:(void (^)(NSError *))failureHandler
                        completionQueue: (dispatch_queue_t) completionQueue
                        delegate: (id) delegate
                        timeout: (NSTimeInterval) timeout{
    return [HTTPRequest sendHttp:url data:nil method:@"GET" addHeaders:headers success:successHandler failure:failureHandler completionQueue:completionQueue delegate:delegate timeout:timeout];
}

// -------------------- A generic http methods --------------------------------
#pragma mark - Delete method implementations

+(void) sendHttp:(NSString*) url data:(NSDictionary*) data
                            method: (NSString *) httpMethod
                            addHeaders:(NSDictionary*) headers
                            success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                            failure:(void (^)(NSError *))failureHandler
                            completionQueue: (dispatch_queue_t) completionQueue
                            delegate: (id) delegate
                            timeout: (NSTimeInterval) timeout{
    if(data) {
        NSError* error = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
        // Check for serialization error
        if (error) {
            if (failureHandler) {
                dispatch_async(completionQueue ?: dispatch_get_main_queue(), ^{
                    failureHandler(error);
                });
            }
            return;
        }
        return [HTTPRequest sendHttpRaw:url data:postData method:httpMethod addHeaders:headers success:successHandler failure:failureHandler completionQueue:completionQueue delegate:delegate timeout:timeout];
    }
    return [HTTPRequest sendHttpRaw:url data:nil method:httpMethod addHeaders:headers success:successHandler failure:failureHandler completionQueue:completionQueue delegate:delegate timeout:timeout];
}

+(void) sendHttpRaw:(NSString*) url data:(NSData*) data
                            method: (NSString *) httpMethod
                            addHeaders:(NSDictionary*) headers
                            success:(void (^)(NSDictionary<NSString*, id> *))successHandler
                            failure:(void (^)(NSError *))failureHandler
                            completionQueue: (dispatch_queue_t) completionQueue
                            delegate: (id) delegate
                            timeout: (NSTimeInterval) timeout{
    
    
    // Set a timeout
    if(timeout < 0.01) timeout = DEFAULT_REQUEST_TIME_OUT;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                    // Ignore all local cached results
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:timeout];
    
    // Serialize payload
    if(data) {
        [request setHTTPBody:data];
    }
    
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfiguration.HTTPAdditionalHeaders = headers;
    
    NSURLSession *session;
    
    if(delegate) session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:delegate delegateQueue:nil];
    else session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    // Formulate request method & Limit to send/accepts json content
    [request setHTTPMethod:httpMethod];
    if(headers && [headers objectForKey:@"Content-Type"]){
        [request addValue:[headers objectForKey:@"Content-Type"] forHTTPHeaderField:@"Content-Type"];
    }else{
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    // Implement post task and execute
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
            if (failureHandler) {
                dispatch_async(completionQueue? completionQueue: dispatch_get_main_queue(), ^{
                    failureHandler(error);
                });
            }
        }else{
            
            NSInteger statusCode = 200;
            
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                
                statusCode = [(NSHTTPURLResponse *)response statusCode];
                
                if (statusCode >= 400) {
                    
                    NSString * reason = data? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]:@"HTTPFailureStatusReceived";
                    
                    NSError* httpStatusError = [[NSError alloc] initWithDomain:reason code:statusCode userInfo:nil];
                    
                    // Optional debug parameter
                    // NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    // TODO: Refine httpStatusError
                    
                    if (failureHandler) {
                        dispatch_async(completionQueue ? completionQueue: dispatch_get_main_queue(), ^{
                            failureHandler(httpStatusError);
                        });
                    }
                    return;
                }
            }
            
            // All condition checks are done, call success handler
            if(successHandler){
                // Process json
                id jsonData;
                if(data) jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSDictionary* jsonDict;
                
                if([jsonData isKindOfClass:[NSDictionary class]]){
                    jsonDict = (NSDictionary<NSString*, id>* )jsonData;
                }
                dispatch_async(completionQueue ? completionQueue: dispatch_get_main_queue(), ^{
                    successHandler(jsonDict);
                });
            }
        }
        
    }];
    
    [task resume];
    
}

+(void) getRawData:(NSString* ) url addHeaders:(NSDictionary*) headers
           success:(void (^)(NSData *))successHandler
           failure:(void (^)(NSError *))failureHandler{
    return [HTTPRequest sendHTTPForRawData:url data:nil method:@"GET" addHeaders:headers success:successHandler failure:failureHandler completionQueue:nil delegate:nil timeout:0];
}

+(void) sendHTTPForRawData:(NSString*) url data:(NSData*) data
                  method: (NSString *) httpMethod
              addHeaders:(NSDictionary*) headers
                 success:(void (^)(NSData *))successHandler
                 failure:(void (^)(NSError *))failureHandler
         completionQueue: (dispatch_queue_t) completionQueue
                delegate: (id) delegate
                 timeout: (NSTimeInterval) timeout{
    
    
    // Set a timeout
    if(timeout < 0.01) timeout = DEFAULT_REQUEST_TIME_OUT;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                    // Ignore all local cached results
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:timeout];
    // Serialize payload
    if(data) {
        [request setHTTPBody:data];
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfiguration.HTTPAdditionalHeaders = headers;
    
    NSURLSession *session;
    
    if(delegate) session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:delegate delegateQueue:nil];
    else session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    // Formulate request method & Limit to send/accepts json content
    [request setHTTPMethod:httpMethod];
    if(headers && [headers objectForKey:@"Content-Type"]){
        [request addValue:[headers objectForKey:@"Content-Type"] forHTTPHeaderField:@"Content-Type"];
    }else{
        [request addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    }
    // [request addValue:@"application/octet-stream" forHTTPHeaderField:@"Accept"];
    
    
    // Implement post task and execute
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
            if (failureHandler) {
                dispatch_async(completionQueue? completionQueue: dispatch_get_main_queue(), ^{
                    failureHandler(error);
                });
            }
        }else{
            
            NSInteger statusCode = 200;
            
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                
                statusCode = [(NSHTTPURLResponse *)response statusCode];
                
                if (statusCode >= 400) {

                    NSString * reason = data? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]:@"HTTPFailureStatusReceived";
                    
                    NSError* httpStatusError = [[NSError alloc] initWithDomain:reason code:statusCode userInfo:nil];
                    
                    if (failureHandler) {
                        dispatch_async(completionQueue ? completionQueue: dispatch_get_main_queue(), ^{
                            failureHandler(httpStatusError);
                        });
                    }
                    return;
                }
            }
            
            // All condition checks are done, call success handler
            if(successHandler){
                dispatch_async(completionQueue ? completionQueue: dispatch_get_main_queue(), ^{
                    successHandler(data);
                });
            }
        }
        
    }];
    
    [task resume];
    
}


@end
