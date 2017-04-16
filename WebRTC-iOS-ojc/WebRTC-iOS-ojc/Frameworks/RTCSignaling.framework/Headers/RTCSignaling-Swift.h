// Generated by Apple Swift version 3.1 (swiftlang-802.0.51 clang-802.0.41)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if defined(__has_attribute) && __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if defined(__has_attribute) && __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
@import ObjectiveC;
@import WebRTC;
@import Dispatch;
@import Security.CipherSuite;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"

@interface NSNumber (SWIFT_EXTENSION(RTCSignaling))
@end

@class RTCVideoTrack;
@class RTCAudioTrack;
@class RTCMediaStream;
@protocol RTCClientDelegate;
@class UIView;

SWIFT_CLASS("_TtC12RTCSignaling9RTCClient")
@interface RTCClient : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) RTCClient * _Nonnull shared;)
+ (RTCClient * _Nonnull)shared SWIFT_WARN_UNUSED_RESULT;
@property (nonatomic, strong) RTCVideoTrack * _Nullable localVideoTrack;
@property (nonatomic, strong) RTCAudioTrack * _Nullable localAudioTrack;
@property (nonatomic, strong) RTCMediaStream * _Nullable localMediaStream;
@property (nonatomic, strong) id <RTCClientDelegate> _Nullable delegate;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
- (void)connectWithServerUrl:(NSString * _Nonnull)serverUrl roomId:(NSString * _Nonnull)roomId delegate:(id <RTCClientDelegate> _Nonnull)delegate;
- (void)setAudioOn:(BOOL)on;
- (void)setVideoOn:(BOOL)on;
- (void)setAudioOutputWithUseSpeaker:(BOOL)useSpeaker;
- (void)setLocalVideoContainerWithView:(UIView * _Nonnull)view;
- (void)disconect;
@end


@interface RTCClient (SWIFT_EXTENSION(RTCSignaling))
@end


@interface RTCClient (SWIFT_EXTENSION(RTCSignaling))
@end


SWIFT_CLASS("_TtC12RTCSignaling15RTCClientConfig")
@interface RTCClientConfig : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull DEFAULT_STUN_SERVER_URL;)
+ (NSString * _Nonnull)DEFAULT_STUN_SERVER_URL SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull DEFAULT_TURN_SERVER_URL;)
+ (NSString * _Nonnull)DEFAULT_TURN_SERVER_URL SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull DEFAULT_PEER_TYPE;)
+ (NSString * _Nonnull)DEFAULT_PEER_TYPE SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) BOOL DEFAULT_ENABLE_DATA_CHANNELS;)
+ (BOOL)DEFAULT_ENABLE_DATA_CHANNELS SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) BOOL DEFAULT_USE_SPEAKER;)
+ (BOOL)DEFAULT_USE_SPEAKER SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) BOOL validateSsl;)
+ (BOOL)validateSsl SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) BOOL audioOnly;)
+ (BOOL)audioOnly SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) BOOL offerToReceiveAudio;)
+ (BOOL)offerToReceiveAudio SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) BOOL offerToReceiveVideo;)
+ (BOOL)offerToReceiveVideo SWIFT_WARN_UNUSED_RESULT;
+ (void)loadWithConfig:(NSDictionary<NSString *, id> * _Nonnull)config;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class RTCPeer;

SWIFT_PROTOCOL("_TtP12RTCSignaling17RTCClientDelegate_")
@protocol RTCClientDelegate
- (void)rtcClientDidSetLocalMediaStreamWithClient:(RTCClient * _Nonnull)client authorized:(BOOL)authorized audioOnly:(BOOL)audioOnly;
- (void)rtcClientDidAddRemoteMediaStreamWithPeer:(RTCPeer * _Nonnull)peer stream:(RTCMediaStream * _Nonnull)stream audioOnly:(BOOL)audioOnly;
@optional
- (void)rtcRemotePeerDidChangeAudioStateWithPeer:(RTCPeer * _Nonnull)peer on:(BOOL)on;
- (void)rtcRemotePeerDidChangeVideoStateWithPeer:(RTCPeer * _Nonnull)peer on:(BOOL)on;
- (void)rtcRemotePeerFailedToGenerateIceCandidateWithPeer:(RTCPeer * _Nonnull)peer;
@end

@class RTCPeerConnection;

SWIFT_CLASS("_TtC12RTCSignaling7RTCPeer")
@interface RTCPeer : NSObject
@property (nonatomic, readonly, strong) RTCPeerConnection * _Null_unspecified peerConnection;
@property (nonatomic, readonly, copy) NSString * _Nonnull peerId;
@property (nonatomic, readonly, copy) NSString * _Nonnull type;
@property (nonatomic, readonly) BOOL oneway;
@property (nonatomic, readonly) BOOL sharemyscreen;
@property (nonatomic, readonly) BOOL enableDataChannels;
@property (nonatomic, readonly, copy) NSString * _Nonnull sid;
@property (nonatomic, readonly, copy) NSString * _Nullable broadcaster;
@property (nonatomic, readonly, strong) RTCClient * _Nonnull parent;
@property (nonatomic, readonly, strong) RTCVideoTrack * _Nullable remoteVideoTrack;
- (void)setRemoteVideoContainerWithView:(UIView * _Nonnull)view;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

@class RTCDataChannel;
@class RTCDataBuffer;

@interface RTCPeer (SWIFT_EXTENSION(RTCSignaling)) <RTCDataChannelDelegate>
/// The data channel state changed.
- (void)dataChannelDidChangeState:(RTCDataChannel * _Nonnull)dataChannel;
/// The data channel successfully received a data buffer.
- (void)dataChannel:(RTCDataChannel * _Nonnull)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer * _Nonnull)buffer;
@end

@class RTCIceCandidate;

@interface RTCPeer (SWIFT_EXTENSION(RTCSignaling)) <RTCPeerConnectionDelegate>
/// Called when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged;
/// Called when media is received on a new stream from remote peer.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didAddStream:(RTCMediaStream * _Nonnull)stream;
/// Called when a remote peer closes a stream.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didRemoveStream:(RTCMediaStream * _Nonnull)stream;
/// Called when negotiation is needed, for example ICE has restarted.
- (void)peerConnectionShouldNegotiate:(RTCPeerConnection * _Nonnull)peerConnection;
/// Called any time the IceConnectionState changes.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState;
/// Called any time the IceGatheringState changes.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState;
/// New ice candidate has been found.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didGenerateIceCandidate:(RTCIceCandidate * _Nonnull)candidate;
/// Called when a group of local Ice candidates have been removed.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didRemoveIceCandidates:(NSArray<RTCIceCandidate *> * _Nonnull)candidates;
/// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection * _Nonnull)peerConnection didOpenDataChannel:(RTCDataChannel * _Nonnull)dataChannel;
@end

@class NSError;
@class NSStream;

SWIFT_CLASS("_TtC12RTCSignaling9WebSocket")
@interface WebSocket : NSObject <NSStreamDelegate>
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull ErrorDomain;)
+ (NSString * _Nonnull)ErrorDomain SWIFT_WARN_UNUSED_RESULT;
@property (nonatomic, strong) dispatch_queue_t _Nonnull callbackQueue;
@property (nonatomic, copy) void (^ _Nullable onConnect)(void);
@property (nonatomic, copy) void (^ _Nullable onDisconnect)(NSError * _Nullable);
@property (nonatomic, copy) void (^ _Nullable onText)(NSString * _Nonnull);
@property (nonatomic, copy) void (^ _Nullable onData)(NSData * _Nonnull);
@property (nonatomic, copy) void (^ _Nullable onPong)(NSData * _Nullable);
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> * _Nonnull headers;
@property (nonatomic) BOOL voipEnabled;
@property (nonatomic) BOOL disableSSLCertValidation;
@property (nonatomic, copy) NSArray<NSNumber *> * _Nullable enabledSSLCipherSuites;
@property (nonatomic, copy) NSString * _Nullable origin;
@property (nonatomic) NSInteger timeout;
@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readonly, copy) NSURL * _Nonnull currentURL;
/// Used for setting protocols.
- (nonnull instancetype)initWithUrl:(NSURL * _Nonnull)url protocols:(NSArray<NSString *> * _Nullable)protocols OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithUrl:(NSURL * _Nonnull)url writeQueueQOS:(NSQualityOfService)writeQueueQOS protocols:(NSArray<NSString *> * _Nullable)protocols;
/// Connect to the WebSocket server on a background thread.
- (void)connect;
/// Write a string to the websocket. This sends it as a text frame.
/// If you supply a non-nil completion block, I will perform it when the write completes.
/// \param string The string to write.
///
/// \param completion The (optional) completion handler.
///
- (void)writeWithString:(NSString * _Nonnull)string completion:(void (^ _Nullable)(void))completion;
/// Write binary data to the websocket. This sends it as a binary frame.
/// If you supply a non-nil completion block, I will perform it when the write completes.
/// \param data The data to write.
///
/// \param completion The (optional) completion handler.
///
- (void)writeWithData:(NSData * _Nonnull)data completion:(void (^ _Nullable)(void))completion;
/// Write a ping to the websocket. This sends it as a control frame.
/// Yodel a   sound  to the planet.    This sends it as an astroid. http://youtu.be/Eu5ZJELRiJ8?t=42s
- (void)writeWithPing:(NSData * _Nonnull)ping completion:(void (^ _Nullable)(void))completion;
/// Delegate for the stream methods. Processes incoming bytes
- (void)stream:(NSStream * _Nonnull)aStream handleEvent:(NSStreamEvent)eventCode;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

#pragma clang diagnostic pop