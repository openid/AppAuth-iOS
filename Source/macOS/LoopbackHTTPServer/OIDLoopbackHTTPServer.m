/*! @file OIDLoopbackHTTPServer.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2016 The AppAuth Authors.
    @copydetails
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 */

#import "OIDLoopbackHTTPServer.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@implementation HTTPServer

- (id)init {
    connClass = [HTTPConnection self];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (Class)connectionClass {
    return connClass;
}

- (void)setConnectionClass:(Class)value {
    connClass = value;
}

- (NSURL *)documentRoot {
    return docRoot;
}

- (void)setDocumentRoot:(NSURL *)value {
    if (docRoot != value) {
        [docRoot release];
        docRoot = [value copy];
    }
}

// Converts the TCPServer delegate notification into the HTTPServer delegate method.
- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr {
    HTTPConnection *connection = [[connClass alloc] initWithPeerAddress:addr inputStream:istr outputStream:ostr forServer:self];
    [connection setDelegate:[self delegate]];
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(HTTPServer:didMakeNewConnection:)]) {
        [[self delegate] HTTPServer:self didMakeNewConnection:connection];
    }
    // The connection at this point is turned loose to exist on its
    // own, and not released or autoreleased.  Alternatively, the
    // HTTPServer could keep a list of connections, and HTTPConnection
    // would have to tell the server to delete one at invalidation
    // time.  This would perhaps be more correct and ensure no
    // spurious leaks get reported by the tools, but HTTPServer
    // has nothing further it wants to do with the HTTPConnections,
    // and would just be "owning" the connections for form.
}

@end


@implementation HTTPConnection

- (id)init {
    [self dealloc];
    return nil;
}

- (id)initWithPeerAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr forServer:(HTTPServer *)serv {
    peerAddress = [addr copy];
    server = serv;
    istream = [istr retain];
    ostream = [ostr retain];
    [istream setDelegate:self];
    [ostream setDelegate:self];
    [istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:(id)kCFRunLoopCommonModes];
    [ostream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:(id)kCFRunLoopCommonModes];
    [istream open];
    [ostream open];
    isValid = YES;
    return self;
}

- (void)dealloc {
    [self invalidate];
    [peerAddress release];
    [super dealloc];
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)value {
    delegate = value;
}

- (NSData *)peerAddress {
    return peerAddress;
}

- (HTTPServer *)server {
    return server;
}

- (HTTPServerRequest *)nextRequest {
    unsigned idx, cnt = requests ? [requests count] : 0;
    for (idx = 0; idx < cnt; idx++) {
        id obj = [requests objectAtIndex:idx];
        if ([obj response] == nil) {
            return obj;
        }
    }
    return nil;
}

- (BOOL)isValid {
    return isValid;
}

- (void)invalidate {
    if (isValid) {
        isValid = NO;
        [istream close];
        [ostream close];
        [istream release];
        [ostream release];
        istream = nil;
        ostream = nil;
        [ibuffer release];
        [obuffer release];
        ibuffer = nil;
        obuffer = nil;
        [requests release];
        requests = nil;
        [self release];
        // This last line removes the implicit retain the HTTPConnection
        // has on itself, given by the HTTPServer when it abandoned the
        // new connection.
    }
}

// YES return means that a complete request was parsed, and the caller
// should call again as the buffered bytes may have another complete
// request available.
- (BOOL)processIncomingBytes {
    CFHTTPMessageRef working = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
    CFHTTPMessageAppendBytes(working, [ibuffer bytes], [ibuffer length]);

    // This "try and possibly succeed" approach is potentially expensive
    // (lots of bytes being copied around), but the only API available for
    // the server to use, short of doing the parsing itself.

    // HTTPConnection does not handle the chunked transfer encoding
    // described in the HTTP spec.  And if there is no Content-Length
    // header, then the request is the remainder of the stream bytes.

    if (CFHTTPMessageIsHeaderComplete(working)) {
        NSString *contentLengthValue = [(NSString *)CFHTTPMessageCopyHeaderFieldValue(working, (CFStringRef)@"Content-Length") autorelease];

        unsigned contentLength = contentLengthValue ? [contentLengthValue intValue] : 0;
        NSData *body = [(NSData *)CFHTTPMessageCopyBody(working) autorelease];
        unsigned bodyLength = [body length];
        if (contentLength <= bodyLength) {
            NSData *newBody = [NSData dataWithBytes:[body bytes] length:contentLength];
            [ibuffer setLength:0];
            [ibuffer appendBytes:([body bytes] + contentLength) length:(bodyLength - contentLength)];
            CFHTTPMessageSetBody(working, (CFDataRef)newBody);
        } else {
            CFRelease(working);
            return NO;
        }
    } else {
        return NO;
    }

    HTTPServerRequest *request = [[HTTPServerRequest alloc] initWithRequest:working connection:self];
    if (!requests) {
        requests = [[NSMutableArray alloc] init];
    }
    [requests addObject:request];
    if (delegate && [delegate respondsToSelector:@selector(HTTPConnection:didReceiveRequest:)]) {
        [delegate HTTPConnection:self didReceiveRequest:request];
    } else {
        [self performDefaultRequestHandling:request];
    }

    CFRelease(working);
    return YES;
}

- (void)processOutgoingBytes {
    // The HTTP headers, then the body if any, then the response stream get
    // written out, in that order.  The Content-Length: header is assumed to
    // be properly set in the response.  Outgoing responses are processed in
    // the order the requests were received (required by HTTP).

    // Write as many bytes as possible, from buffered bytes, response
    // headers and body, and response stream.

    if (![ostream hasSpaceAvailable]) {
        return;
    }

    unsigned olen = [obuffer length];
    if (0 < olen) {
        int writ = [ostream write:[obuffer bytes] maxLength:olen];
        // buffer any unwritten bytes for later writing
        if (writ < olen) {
            memmove([obuffer mutableBytes], [obuffer mutableBytes] + writ, olen - writ);
            [obuffer setLength:olen - writ];
            return;
        }
        [obuffer setLength:0];
    }

    unsigned cnt = requests ? [requests count] : 0;
    HTTPServerRequest *req = (0 < cnt) ? [requests objectAtIndex:0] : nil;

    CFHTTPMessageRef cfresp = req ? [req response] : NULL;
    if (!cfresp) return;

    if (!obuffer) {
        obuffer = [[NSMutableData alloc] init];
    }

    if (!firstResponseDone) {
        firstResponseDone = YES;
        NSData *serialized = [(NSData *)CFHTTPMessageCopySerializedMessage(cfresp) autorelease];
        unsigned olen = [serialized length];
        if (0 < olen) {
            int writ = [ostream write:[serialized bytes] maxLength:olen];
            if (writ < olen) {
                // buffer any unwritten bytes for later writing
                [obuffer setLength:(olen - writ)];
                memmove([obuffer mutableBytes], [serialized bytes] + writ, olen - writ);
                return;
            }
        }
    }

    NSInputStream *respStream = [req responseBodyStream];
    if (respStream) {
        if ([respStream streamStatus] == NSStreamStatusNotOpen) {
            [respStream open];
        }
        // read some bytes from the stream into our local buffer
        [obuffer setLength:16 * 1024];
        int read = [respStream read:[obuffer mutableBytes] maxLength:[obuffer length]];
        [obuffer setLength:read];
    }

    if (0 == [obuffer length]) {
        // When we get to this point with an empty buffer, then the
        // processing of the response is done. If the input stream
        // is closed or at EOF, then no more requests are coming in.
        if (delegate && [delegate respondsToSelector:@selector(HTTPConnection:didSendResponse:)]) {
            [delegate HTTPConnection:self didSendResponse:req];
        }
        [requests removeObjectAtIndex:0];
        firstResponseDone = NO;
        if ([istream streamStatus] == NSStreamStatusAtEnd && [requests count] == 0) {
            [self invalidate];
        }
        return;
    }

    olen = [obuffer length];
    if (0 < olen) {
        int writ = [ostream write:[obuffer bytes] maxLength:olen];
        // buffer any unwritten bytes for later writing
        if (writ < olen) {
            memmove([obuffer mutableBytes], [obuffer mutableBytes] + writ, olen - writ);
        }
        [obuffer setLength:olen - writ];
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
    switch(streamEvent) {
    case NSStreamEventHasBytesAvailable:;
        uint8_t buf[16 * 1024];
        uint8_t *buffer = NULL;
        unsigned int len = 0;
        if (![istream getBuffer:&buffer length:&len]) {
            int amount = [istream read:buf maxLength:sizeof(buf)];
            buffer = buf;
            len = amount;
        }
        if (0 < len) {
            if (!ibuffer) {
                ibuffer = [[NSMutableData alloc] init];
            }
            [ibuffer appendBytes:buffer length:len];
        }
        do {} while ([self processIncomingBytes]);
        break;
    case NSStreamEventHasSpaceAvailable:;
        [self processOutgoingBytes];
        break;
    case NSStreamEventEndEncountered:;
        [self processIncomingBytes];
        if (stream == ostream) {
            // When the output stream is closed, no more writing will succeed and
            // will abandon the processing of any pending requests and further
            // incoming bytes.
            [self invalidate];
        }
        break;
    case NSStreamEventErrorOccurred:;
        NSLog(@"HTTPServer stream error: %@", [stream streamError]);
        break;
    default:
        break;
    }
}

- (void)performDefaultRequestHandling:(HTTPServerRequest *)mess {
    CFHTTPMessageRef request = [mess request];

    NSString *vers = [(id)CFHTTPMessageCopyVersion(request) autorelease];
    if (!vers || ![vers isEqual:(id)kCFHTTPVersion1_1]) {
        CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 505, NULL, (CFStringRef)vers); // Version Not Supported
        [mess setResponse:response];
        CFRelease(response);
        return;
    }

    NSString *method = [(id)CFHTTPMessageCopyRequestMethod(request) autorelease];
    if (!method) {
        CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 400, NULL, kCFHTTPVersion1_1); // Bad Request
        [mess setResponse:response];
        CFRelease(response);
        return;
    }

    if ([method isEqual:@"GET"] || [method isEqual:@"HEAD"]) {
        NSURL *uri = [(NSURL *)CFHTTPMessageCopyRequestURL(request) autorelease];
        NSURL *url = [NSURL URLWithString:[uri path] relativeToURL:[server documentRoot]];
        NSData *data = [NSData dataWithContentsOfURL:url];

        if (!data) {
            CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 404, NULL, kCFHTTPVersion1_1); // Not Found
            [mess setResponse:response];
            CFRelease(response);
            return;
        }

        CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1); // OK
        CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Length", (CFStringRef)[NSString stringWithFormat:@"%d", [data length]]);
        if ([method isEqual:@"GET"]) {
            CFHTTPMessageSetBody(response, (CFDataRef)data);
        }
        [mess setResponse:response];
        CFRelease(response);
        return;
    }

    CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 405, NULL, kCFHTTPVersion1_1); // Method Not Allowed
    [mess setResponse:response];
    CFRelease(response);
}

@end


@implementation HTTPServerRequest

- (id)init {
    [self dealloc];
    return nil;
}

- (id)initWithRequest:(CFHTTPMessageRef)req connection:(HTTPConnection *)conn {
    connection = conn;
    request = (CFHTTPMessageRef)CFRetain(req);
    return self;
}

- (void)dealloc {
    if (request) CFRelease(request);
    if (response) CFRelease(response);
    [responseStream release];
    [super dealloc];
}

- (HTTPConnection *)connection {
    return connection;
}

- (CFHTTPMessageRef)request {
    return request;
}

- (CFHTTPMessageRef)response {
    return response;
}

- (void)setResponse:(CFHTTPMessageRef)value {
    if (value != response) {
        if (response) CFRelease(response);
        response = (CFHTTPMessageRef)CFRetain(value);
        if (response) {
            // check to see if the response can now be sent out
            [connection processOutgoingBytes];
        }
    }
}

- (NSInputStream *)responseBodyStream {
    return responseStream;
}

- (void)setResponseBodyStream:(NSInputStream *)value {
    if (value != responseStream) {
        [responseStream release];
        responseStream = [value retain];
    }
}

@end

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
    addr4.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
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
    memcpy(&(addr6.sin6_addr), &in6addr_loopback, sizeof(addr6.sin6_addr));
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
    if (ipv4socket) {
      CFSocketInvalidate(ipv4socket);
      CFRelease(ipv4socket);
      ipv4socket = NULL;
    }
    if (ipv6socket) {
      CFSocketInvalidate(ipv6socket);
      CFRelease(ipv6socket);
      ipv6socket = NULL;
    }
    return YES;
}

@end
