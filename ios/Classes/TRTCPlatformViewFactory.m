//
//  TRTCPlatformViewFactory.m
//  flutter_trtc_plugin
//
//  Created by gejianmin on 2020/3/3.
//

#import "TRTCPlatformViewFactory.h"
#import "TRTCVideoView.h"
static TRTCPlatformViewFactory * g_factory = nil;
@interface TRTCPlatformViewFactory()

@property(nonatomic,strong) NSMutableDictionary<NSNumber*,TRTCVideoView*>  * views;

@end

@implementation TRTCPlatformViewFactory

- (instancetype)init{
    self = [super init];
    if (self) {
        _views = [[NSMutableDictionary alloc]init];
//        _views = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_factory = [[TRTCPlatformViewFactory alloc]init];
    });
    return g_factory;
}
+(void)release{
    if(g_factory){
        g_factory = nil;
    }
}

//-(NSObject<FlutterMessageCodec> *)createArgsCodec{
//    return [FlutterStandardMessageCodec sharedInstance];
//}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
//    TRTCVideoView *tRTCVideoView = [[TRTCVideoView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    
    if (args != nil) {
        NSDictionary *dict = (NSDictionary*)args;
        NSNumber *originId = dict[@"origin"];
        if (originId != nil) {
            TRTCVideoView *existView = self.views[originId];
            if (existView != nil) {
                [self removeView:originId];
                [self addView:existView viewID:@(viewId)];
                return existView;
            }
        }
    }
    
    TRTCVideoView *view = [[TRTCVideoView alloc] initWithRect:frame viewID:viewId sink:_sink];
    [self addView:view viewID:@(viewId)];
    NSLog(@"self.views: %d", self.views.count);
    return view;
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (BOOL)addView:(TRTCVideoView *)view viewID:(NSNumber *)viewId {
    if(!viewId || !view)
        return NO;

    [self.views setObject:view forKey:viewId];

    return YES;
}

- (BOOL)removeView:(NSNumber *)viewId {
    if(!viewId)
        return NO;
    
//    if(![[self.views allKeys] containsObject:viewId])
//        return NO;
    if (![self.views objectForKey:viewId]) {
        return NO;
    }
    
    [self.views removeObjectForKey:viewId];
    return YES;
}

- (TRTCVideoView *)getPlatformView:(NSNumber *) viewId {
    if(!viewId)
        return nil;
    
    return [self.views objectForKey:viewId];
}
-(void)setEventSink:(FlutterEventSink)sink{
    if(!_sink){
        _sink = sink;
    }
}

@end
