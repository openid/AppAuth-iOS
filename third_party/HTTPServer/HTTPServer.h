/*
	    File: HTTPServer.h
	Abstract: HTTPServer, HTTPConnection, and HTTPServerRequest classes.
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
 File: HTTPServer.h
 
 Abstract: Interface description for a basic HTTP server Foundation class
*/ 

#import "TCPServer.h"

@class HTTPConnection, HTTPServerRequest;

@interface HTTPServer : TCPServer {
@private
    Class connClass;
    NSURL *docRoot;
}

- (Class)connectionClass;
- (void)setConnectionClass:(Class)value;
// used to configure the subclass of HTTPConnection to create when  
// a new connection comes in; by default, this is HTTPConnection

- (NSURL *)documentRoot;
- (void)setDocumentRoot:(NSURL *)value;

@end

@interface HTTPServer (HTTPServerDelegateMethods)
- (void)HTTPServer:(HTTPServer *)serv didMakeNewConnection:(HTTPConnection *)conn;
// If the delegate implements this method, this is called  
// by an HTTPServer when a new connection comes in.  If the
// delegate wishes to refuse the connection, then it should
// invalidate the connection object from within this method.
@end


// This class represents each incoming client connection.
@interface HTTPConnection : NSObject {
@private
    id delegate;
    NSData *peerAddress;
    HTTPServer *server;
    NSMutableArray *requests;
    NSInputStream *istream;
    NSOutputStream *ostream;
    NSMutableData *ibuffer;
    NSMutableData *obuffer;
    BOOL isValid;
    BOOL firstResponseDone;
}

- (id)initWithPeerAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr forServer:(HTTPServer *)serv;

- (id)delegate;
- (void)setDelegate:(id)value;

- (NSData *)peerAddress;

- (HTTPServer *)server;

- (HTTPServerRequest *)nextRequest;
// get the next request that needs to be responded to

- (BOOL)isValid;
- (void)invalidate;
// shut down the connection

- (void)performDefaultRequestHandling:(HTTPServerRequest *)sreq;
// perform the default handling action: GET and HEAD requests for files
// in the local file system (relative to the documentRoot of the server)

@end

@interface HTTPConnection (HTTPConnectionDelegateMethods)
- (void)HTTPConnection:(HTTPConnection *)conn didReceiveRequest:(HTTPServerRequest *)mess;
- (void)HTTPConnection:(HTTPConnection *)conn didSendResponse:(HTTPServerRequest *)mess;
// The "didReceiveRequest:" is the most interesting -- 
// tells the delegate when a new request comes in.
@end


// As NSURLRequest and NSURLResponse are not entirely suitable for use from 
// the point of view of an HTTP server, we use CFHTTPMessageRef to encapsulate
// requests and responses.  This class packages the (future) response with a
// request and other info for convenience.
@interface HTTPServerRequest : NSObject {
@private
    HTTPConnection *connection;
    CFHTTPMessageRef request;
    CFHTTPMessageRef response;
    NSInputStream *responseStream;
}

- (id)initWithRequest:(CFHTTPMessageRef)req connection:(HTTPConnection *)conn;

- (HTTPConnection *)connection;

- (CFHTTPMessageRef)request;

- (CFHTTPMessageRef)response;
- (void)setResponse:(CFHTTPMessageRef)value;
// The response may include a body.  As soon as the response is set, 
// the response may be written out to the network.

- (NSInputStream *)responseBodyStream;
- (void)setResponseBodyStream:(NSInputStream *)value;
// If there is to be a response body stream (when, say, a big
// file is to be returned, rather than reading the whole thing
// into memory), then it must be set on the request BEFORE the
// response [headers] itself.

@end

