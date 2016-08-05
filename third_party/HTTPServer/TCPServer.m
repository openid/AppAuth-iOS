/*
     File: TCPServer.m
 Abstract: TCPServer class.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

/*
 File: TCPServer.m
 
 Abstract: Interface description for a basic TCP/IP server Foundation class
*/ 

#import "TCPServer.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

NSString * const TCPServerErrorDomain = @"TCPServerErrorDomain";

@implementation TCPServer

- (id)init {
    return self;
}

- (void)dealloc {
    [self stop];
    [domain release];
    [name release];
    [type release];
    [super dealloc];
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)value {
    delegate = value;
}

- (NSString *)domain {
    return domain;
}

- (void)setDomain:(NSString *)value {
    if (domain != value) {
        [domain release];
        domain = [value copy];
    }
}

- (NSString *)name {
    return name;
}

- (void)setName:(NSString *)value {
    if (name != value) {
        [name release];
        name = [value copy];
    }
}

- (NSString *)type {
    return type;
}

- (void)setType:(NSString *)value {
    if (type != value) {
        [type release];
        type = [value copy];
    }
}

- (uint16_t)port {
    return port;
}

- (void)setPort:(uint16_t)value {
    port = value;
}

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr {
    // if the delegate implements the delegate method, call it  
    if (delegate && [delegate respondsToSelector:@selector(TCPServer:didReceiveConnectionFrom:inputStream:outputStream:)]) { 
        [delegate TCPServer:self didReceiveConnectionFromAddress:addr inputStream:istr outputStream:ostr];
    }
}

// This function is called by CFSocket when a new connection comes in.
// We gather some data here, and convert the function call to a method
// invocation on TCPServer.
static void TCPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    TCPServer *server = (TCPServer *)info;
    if (kCFSocketAcceptCallBack == type) { 
        // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        uint8_t name[SOCK_MAXADDRLEN];
        socklen_t namelen = sizeof(name);
        NSData *peer = nil;
        if (0 == getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen)) {
            peer = [NSData dataWithBytes:name length:namelen];
        }
        CFReadStreamRef readStream = NULL;
	CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
        if (readStream && writeStream) {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            [server handleNewConnectionFromAddress:peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream];
        } else {
            // on any failure, need to destroy the CFSocketNativeHandle 
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}

- (BOOL)start:(NSError **)error {
    CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
    ipv4socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&TCPServerAcceptCallBack, &socketCtxt);
    ipv6socket = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&TCPServerAcceptCallBack, &socketCtxt);

    if (NULL == ipv4socket || NULL == ipv6socket) {
        if (error) *error = [[NSError alloc] initWithDomain:TCPServerErrorDomain code:kTCPServerNoSocketsAvailable userInfo:nil];
        if (ipv4socket) CFRelease(ipv4socket);
        if (ipv6socket) CFRelease(ipv6socket);
        ipv4socket = NULL;
        ipv6socket = NULL;
        return NO;
    }

    int yes = 1;
    setsockopt(CFSocketGetNative(ipv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    setsockopt(CFSocketGetNative(ipv6socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

    // set up the IPv4 endpoint; if port is 0, this will cause the kernel to choose a port for us
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(port);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];

    if (kCFSocketSuccess != CFSocketSetAddress(ipv4socket, (CFDataRef)address4)) {
        if (error) *error = [[NSError alloc] initWithDomain:TCPServerErrorDomain code:kTCPServerCouldNotBindToIPv4Address userInfo:nil];
        if (ipv4socket) CFRelease(ipv4socket);
        if (ipv6socket) CFRelease(ipv6socket);
        ipv4socket = NULL;
        ipv6socket = NULL;
        return NO;
    }
    
    if (0 == port) {
        // now that the binding was successful, we get the port number 
        // -- we will need it for the v6 endpoint and for the NSNetService
        NSData *addr = [(NSData *)CFSocketCopyAddress(ipv4socket) autorelease];
        memcpy(&addr4, [addr bytes], [addr length]);
        port = ntohs(addr4.sin_port);
    }

    // set up the IPv6 endpoint
    struct sockaddr_in6 addr6;
    memset(&addr6, 0, sizeof(addr6));
    addr6.sin6_len = sizeof(addr6);
    addr6.sin6_family = AF_INET6;
    addr6.sin6_port = htons(port);
    memcpy(&(addr6.sin6_addr), &in6addr_any, sizeof(addr6.sin6_addr));
    NSData *address6 = [NSData dataWithBytes:&addr6 length:sizeof(addr6)];

    if (kCFSocketSuccess != CFSocketSetAddress(ipv6socket, (CFDataRef)address6)) {
        if (error) *error = [[NSError alloc] initWithDomain:TCPServerErrorDomain code:kTCPServerCouldNotBindToIPv6Address userInfo:nil];
        if (ipv4socket) CFRelease(ipv4socket);
        if (ipv6socket) CFRelease(ipv6socket);
        ipv4socket = NULL;
        ipv6socket = NULL;
        return NO;
    }

    // set up the run loop sources for the sockets
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, ipv4socket, 0);
    CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
    CFRelease(source4);

    CFRunLoopSourceRef source6 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, ipv6socket, 0);
    CFRunLoopAddSource(cfrl, source6, kCFRunLoopCommonModes);
    CFRelease(source6);

    // we can only publish the service if we have a type to publish with
    if (nil != type) {
        NSString *publishingDomain = domain ? domain : @"";
        NSString *publishingName = nil;
        if (nil != name) {
            publishingName = name;
        } else {
            NSString * thisHostName = [[NSProcessInfo processInfo] hostName];
            if ([thisHostName hasSuffix:@".local"]) {
                publishingName = [thisHostName substringToIndex:([thisHostName length] - 6)];
            }
        }
        netService = [[NSNetService alloc] initWithDomain:publishingDomain type:type name:publishingName port:port];
        [netService publish];
    }

    return YES;
}

- (BOOL)stop {
    [netService stop];
    [netService release];
    netService = nil;
    CFSocketInvalidate(ipv4socket);
    CFSocketInvalidate(ipv6socket);
    CFRelease(ipv4socket);
    CFRelease(ipv6socket);
    ipv4socket = NULL;
    ipv6socket = NULL;
    return YES;
}

@end

