WebSocketUpgrade identifiable requirements

# Chapter 3.1: HTTP Version
## 3.1-1 MUST
The version of an HTTP message is indicated by an HTTP-Version field
in the first line of the message.

    HTTP-Version   = "HTTP" "/" 1*DIGIT "." 1*DIGIT

## 3.1-2 MUST
Note that the major and minor numbers MUST be treated as separate
integers

## 3.1-3 MAY
Note that the major and minor numbers must be treated as separate
integers and that each MAY be incremented higher than a single digit.

## 3.1-4 MUST
Leading zeros MUST be ignored by recipients.

## 3.1-5 MUST NOT
Leading zeros must be ignored by recipients and MUST NOT be sent.

## 3.1-6 MUST @inapplicable
An application that sends a request or response message that includes
HTTP-Version of "HTTP/1.1" MUST be at least conditionally compliant
with this specification.

## 3.1-7 SHOULD
Applications that are at least conditionally
compliant with this specification SHOULD use an HTTP-Version of
"HTTP/1.1" in their messages...

## 3.1-8 MUST
Applications that are at least conditionally
compliant with this specification should use an HTTP-Version of
"HTTP/1.1" in their messages, and MUST do so for any message that is
not compatible with HTTP/1.0.

## 3.1-9 @inapplicable
The HTTP version of an application is the highest HTTP version for
which the application is at least conditionally compliant.

## 3.1-10 MUST NOT @inapplicable
Since the protocol version indicates the protocol capability of the
sender, a proxy/gateway MUST NOT send a message with a version
indicator which is greater than its actual version.

## 3.1-11 MUST @inapplicable
If a higher version request is received, the proxy/gateway MUST either downgrade
the request version, or respond with an error, or switch to tunnel
behavior.

## 3.1-12 MUST @inapplicable
Due to interoperability problems with HTTP/1.0 proxies discovered
since the publication of RFC 2068[33], caching proxies MUST
upgrade the request to the highest version they support.

## 3.1-13 MAY @inapplicable
Due to interoperability problems with HTTP/1.0 proxies discovered
since the publication of RFC 2068[33], gateways
MAY upgrade the request to the highest version
they support.

## 3.1-14 MUST NOT @inapplicable
Due to interoperability problems with HTTP/1.0 proxies discovered
since the publication of RFC 2068[33], tunnels MUST NOT upgrade the
request to the highest version they support.

## 3.1-15 MUST @inapplicable
The proxy/gateway's response to that request MUST be in
the same major version as the request.

# Chapter 3.2: Uniform Resource Identifiers

## 3.2-1
For definitive information on
URL syntax and semantics, see "Uniform Resource Identifiers (URI):
Generic Syntax and Semantics," RFC 2396 [42] (which replaces RFCs
1738 [4] and RFC 1808 [11]).

## 3.2-2
The HTTP protocol does not place any a priori limit on the length of
a URI.

## 3.2-3 MUST @inapplicable
Servers MUST be able to handle the URI of any resource they serve.

## 3.2-4 SHOULD @inapplicable
Servers must be able to handle the URI of any resource they
serve, and SHOULD be able to handle URIs of unbounded length if they
provide GET-based forms that could generate such URIs.

## 3.2-5 @inapplicable
The "http" scheme is used to locate network resources via the HTTP
protocol.

## 3.2-6
This section defines the scheme-specific syntax and
semantics for http URLs.

   http_URL = "http:" "//" host [ ":" port ] [ abs_path [ "?" query ]]

## 3.2-7
If the port is empty or not given, port 80 is assumed.

## 3.2-8
The semantics
are that the identified resource is located at the server listening
for TCP connections on that port of that host, and the Request-URI
for the resource is abs_path (section 5.1.2).

## 3.2-9 SHOULD @inapplicable
The use of IP addresses in URLs SHOULD be avoided whenever possible
(see RFC 1900 [24]).

## 3.2-10
If the abs_path is not present in the URL, it MUST be given as "/" when
used as a Request-URI for a resource (section 5.1.2).

## 3.2-11 @inapplicable
If a proxy receives a host name which is not a fully qualified domain name, it
MAY add its domain to the host name it received.

## 3.2-12 @inapplicable
If a proxy receives a fully qualified domain name, the proxy MUST NOT change
the host name.

## 3.2-13 SHOULD
When comparing two URIs to decide if they match or not, a client
SHOULD use a case-sensitive octet-by-octet comparison of the entire
URIs, with these exceptions:

## 3.2-14 SHOULD
- A port that is empty or not given is equivalent to the default
port for that URI-reference;

## 3.2-15
- Comparisons of host names MUST be case-insensitive;

## 3.2-16
- Comparisons of scheme names MUST be case-insensitive;

## 3.2-17
- An empty abs_path is equivalent to an abs_path of "/".

## 3.2-18
Characters other than those in the "reserved" and "unsafe" sets (see
RFC 2396 [42]) are equivalent to their ""%" HEX HEX" encoding.

For example, the following three URIs are equivalent:

    http://abc.com:80/~smith/home.html
    http://ABC.com/%7Esmith/home.html
    http://ABC.com:/%7esmith/home.html

# Chapter 3.3: Date/Time Formats
HTTP applications have historically allowed three different formats
for the representation of date/time stamps:

    Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
    Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
    Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format

## 3.3-1
The first format is preferred as an Internet standard and represents
a fixed-length subset of that defined by RFC 1123 [8] (an update to
RFC 822 [9]).

## 3.3-2 MUST
HTTP/1.1 clients and servers that parse the date value MUST accept
all three formats (for compatibility with HTTP/1.0)...

## 3.3-3 MUST
HTTP/1.1 clients and servers that parse the date value must accept
all three formats (for compatibility with HTTP/1.0), though they MUST
only generate the RFC 1123 format for representing HTTP-date values
in header fields. See section 19.3 for further information.

## 3.3-4 MUST
All HTTP date/time stamps MUST be represented in Greenwich Mean Time
(GMT), without exception. For the purposes of HTTP, GMT is exactly
equal to UTC (Coordinated Universal Time).

## 3.3-5 MUST
This is indicated in the
first two formats by the inclusion of "GMT" as the three-letter
abbreviation for time zone, and MUST be assumed when reading the
asctime format.

## 3.3-6 MUST NOT
HTTP-date is case sensitive and MUST NOT include
additional LWS beyond that specifically included as SP in the
grammar.

## 3.3-7
    HTTP-date    = rfc1123-date | rfc850-date | asctime-date
    rfc1123-date = wkday "," SP date1 SP time SP "GMT"
    rfc850-date  = weekday "," SP date2 SP time SP "GMT"
    asctime-date = wkday SP date3 SP time SP 4DIGIT
    date1        = 2DIGIT SP month SP 4DIGIT
                    ; day month year (e.g., 02 Jun 1982)
    date2        = 2DIGIT "-" month "-" 2DIGIT
                    ; day-month-year (e.g., 02-Jun-82)
    date3        = month SP ( 2DIGIT | ( SP 1DIGIT ))
                    ; month day (e.g., Jun  2)
    time         = 2DIGIT ":" 2DIGIT ":" 2DIGIT
                    ; 00:00:00 - 23:59:59
    wkday        = "Mon" | "Tue" | "Wed"
                | "Thu" | "Fri" | "Sat" | "Sun"
    weekday      = "Monday" | "Tuesday" | "Wednesday"
                | "Thursday" | "Friday" | "Saturday" | "Sunday"
    month        = "Jan" | "Feb" | "Mar" | "Apr"
                | "May" | "Jun" | "Jul" | "Aug"
                | "Sep" | "Oct" | "Nov" | "Dec"

## 3.3-8
    Note: HTTP requirements for the date/time stamp format apply only
    to their usage within the protocol stream. Clients and servers are
    not required to use these formats for user presentation, request
    logging, etc.

## 3.3-9
Some HTTP header fields allow a time value to be specified as an
integer number of seconds, represented in decimal, after the time
that the message was received.

    delta-seconds  = 1*DIGIT

# Chapter 3.4: Character Sets
## 3.4-1
HTTP uses the same definition of the term "character set" as that
described for MIME:
The term "character set" is used in this document to refer to a
method used with one or more tables to convert a sequence of octets
into a sequence of characters. Note that unconditional conversion in
the other direction is not required, in that not all characters may
be available in a given character set and a character set may provide
more than one sequence of octets to represent a particular character.
This definition is intended to allow various kinds of character
encoding, from simple single-table mappings such as US-ASCII to
complex table switching methods such as those that use ISO-2022's
techniques.

## 3.4-2 MUST
 However, the definition associated with a MIME character
set name MUST fully specify the mapping to be performed from octets
to characters.

## 3.4-3
In particular, use of external profiling information
to determine the exact mapping is not permitted.

## 3.4-4
HTTP character sets are identified by case-insensitive tokens. The
complete set of tokens is defined by the IANA Character Set registry
[19].

    charset = token

## 3.4-5 MUST
Although HTTP allows an arbitrary token to be used as a charset
value, any token that has a predefined value within the IANA
Character Set registry [19] MUST represent the character set defined
by that registry.

## 3.4-6 SHOULD
Applications SHOULD limit their use of character
sets to those defined by the IANA registry.

## 3.4-7 MAY
 Some HTTP/1.0 software has interpreted a Content-Type header without
   charset parameter incorrectly to mean "recipient should guess."
   Senders wishing to defeat this behavior MAY include a charset
   parameter even when the charset is ISO-8859-1 and should do so when
   it is known that it will not confuse the recipient.

## 3.4-8 SHOULD
Some HTTP/1.0 software has interpreted a Content-Type header without
charset parameter incorrectly to mean "recipient should guess."
Senders wishing to defeat this behavior may include a charset
parameter even when the charset is ISO-8859-1 and SHOULD do so when
it is known that it will not confuse the recipient.

## 3.4-9 MUST
HTTP/1.1 recipients MUST respect the charset label provided by the sender;

## 3.4-10 MUST
HTTP/1.1 recipients must respect the
charset label provided by the sender; and those user agents that have
a provision to "guess" a charset MUST use the charset from the
content-type field if they support that charset, rather than the
recipient's preference, when initially displaying a document. See
section 3.7.1.

# Chapter 3.8: Product Tokens
## 3.8-1
Product tokens are used to allow communicating applications to
identify themselves by software name and version. Most fields using
product tokens also allow sub-products which form a significant part
of the application to be listed, separated by white space. By
convention, the products are listed in order of their significance
for identifying the application.

    product         = token ["/" product-version]
    product-version = token

Examples:

    User-Agent: CERN-LineMode/2.15 libwww/2.17b3
    Server: Apache/0.8.4

## 3.8-2 SHOULD
Product tokens SHOULD be short and to the point.

## 3.8-3 MUST NOT
They MUST NOT be used for advertising or other non-essential information.

## 3.8-4 MAY
Although any token character MAY appear in a product-version...

## 3.8-5 SHOULD
Although any
token character may appear in a product-version, this token SHOULD
only be used for a version identifier (i.e., successive versions of
the same product SHOULD only differ in the product-version portion of
the product value).

# Chapter 4.1: Message Types
## 4.1-1
HTTP messages consist of requests from client to server and responses
from server to client.

    HTTP-message   = Request | Response     ; HTTP/1.1 messages

## 4.1-2
Request (section 5) and Response (section 6) messages use the generic
message format of RFC 822 [9] for transferring entities (the payload
of the message). Both types of message consist of a start-line, zero
or more header fields (also known as "headers"), an empty line (i.e.,
a line with nothing preceding the CRLF) indicating the end of the
header fields, and possibly a message-body.

    generic-message = start-line
                        *(message-header CRLF)
                        CRLF
                        [ message-body ]
    start-line      = Request-Line | Status-Line

## 4.1-3 SHOULD
In the interest of robustness, servers SHOULD ignore any empty
line(s) received where a Request-Line is expected. In other words, if
the server is reading the protocol stream at the beginning of a
message and receives a CRLF first, it should ignore the CRLF.

## 4.1-4 MUST NOT
Certain buggy HTTP/1.0 client implementations generate extra CRLF's
after a POST request. To restate what is explicitly forbidden by the
BNF, an HTTP/1.1 client MUST NOT preface or follow a request with an
extra CRLF.

# Chapter 4.2: Message Headers

## 4.2-1
HTTP header fields, which include general-header (section 4.5),
request-header (section 5.3), response-header (section 6.2), and
entity-header (section 7.1) fields, follow the same generic format as
that given in Section 3.1 of RFC 822 [9].

## 4.2-2
Each header field consists
of a name followed by a colon (":") and the field value. Field names
are case-insensitive.

## 4.2-3 MAY
The field value MAY be preceded by any amount
of LWS, though a single SP is preferred.

## 4.2-4
Header fields can be
extended over multiple lines by preceding each extra line with at
least one SP or HT.

## 4.2-5
Applications ought to follow "common form", where
one is known or indicated, when generating HTTP constructs, since
there might exist some implementations that fail to accept anything
beyond the common forms.

## 4.2-6
Grammar

    message-header = field-name ":" [ field-value ]
    field-name     = token
    field-value    = *( field-content | LWS )
    field-content  = <the OCTETs making up the field-value
                    and consisting of either *TEXT or combinations
                    of token, separators, and quoted-string>

## 4.2-7 MAY
The field-content does not include any leading or trailing LWS:
linear white space occurring before the first non-whitespace
character of the field-value or after the last non-whitespace
character of the field-value. Such leading or trailing LWS MAY be
removed without changing the semantics of the field value.

## 4.2-8 MAY
Any LWS
that occurs between field-content MAY be replaced with a single SP
before interpreting the field value or forwarding the message
downstream.

## 4.2-9
The order in which header fields with differing field names are
received is not significant. However, it is "good practice" to send
general-header fields first, followed by request-header or response-
header fields, and ending with the entity-header fields.

## 4.2-10 MAY
Multiple message-header fields with the same field-name MAY be
present in a message if and only if the entire field-value for that
header field is defined as a comma-separated list [i.e., #(values)].

## 4.2-11 MUST
It MUST be possible to combine the multiple header fields into one
"field-name: field-value" pair, without changing the semantics of the
message, by appending each subsequent field-value to the first, each
separated by a comma.

## 4.2-12 MUST NOT
The order in which header fields with the same
field-name are received is therefore significant to the
interpretation of the combined field value, and thus a proxy MUST NOT
change the order of these field values when a message is forwarded.

# Chapter 4.4: Message Length
## 4.4-1
The transfer-length of a message is the length of the message-body as
it appears in the message; that is, after any transfer-codings have
been applied. When a message-body is included with a message, the
transfer-length of that body is determined by one of the following
(in order of precedence):

## 4.4-2
1.Any response message which "MUST NOT" include a message-body (such
as the 1xx, 204, and 304 responses and any response to a HEAD
request) is always terminated by the first empty line after the
header fields, regardless of the entity-header fields present in
the message.

## 4.4-3
2.If a Transfer-Encoding header field (section 14.41) is present and
has any value other than "identity", then the transfer-length is
defined by use of the "chunked" transfer-coding (section 3.6),
unless the message is terminated by closing the connection.

## 4.4-4 MUST NOT
3.If a Content-Length header field (section 14.13) is present, its
decimal value in OCTETs represents both the entity-length and the
transfer-length. The Content-Length header field MUST NOT be sent
if these two lengths are different (i.e., if a Transfer-Encoding
header field is present). If a message is received with both a
Transfer-Encoding header field and a Content-Length header field,
the latter must be ignored.

## 4.4-5 MUST
3.If a Content-Length header field (section 14.13) is present, its
decimal value in OCTETs represents both the entity-length and the
transfer-length. The Content-Length header field must not be sent
if these two lengths are different (i.e., if a Transfer-Encoding
header field is present). If a message is received with both a
Transfer-Encoding header field and a Content-Length header field,
the latter MUST be ignored.

## 4.4-6
4.If the message uses the media type "multipart/byteranges", and the
ransfer-length is not otherwise specified, then this self-
elimiting media type defines the transfer-length. This media type
UST NOT be used unless the sender knows that the recipient can arse
it; the presence in a request of a Range header with ultiple byte-
range specifiers from a 1.1 client implies that the lient can parse
multipart/byteranges responses.

A range header might be forwarded by a 1.0 proxy that does not
understand multipart/byteranges; in this case the server MUST
delimit the message using methods defined in items 1,3 or 5 of
this section.

## 4.4-7
5.By the server closing the connection. (Closing the connection
cannot be used to indicate the end of a request body, since that
would leave no possibility for the server to send back a response.)

## 4.4-8 MUST
For compatibility with HTTP/1.0 applications, HTTP/1.1 requests
containing a message-body MUST include a valid Content-Length header
field unless the server is known to be HTTP/1.1 compliant.

## 4.4-9 SHOULD
If a
request contains a message-body and a Content-Length is not given,
the server SHOULD respond with 400 (bad request) if it cannot
determine the length of the message, or with 411 (length required) if
it wishes to insist on receiving a valid Content-Length.

## 4.4-10 MUST
All HTTP/1.1 applications that receive entities MUST accept the
"chunked" transfer-coding (section 3.6), thus allowing this mechanism
to be used for messages when the message length cannot be determined
in advance.

## 4.4-11 MUST NOT
Messages MUST NOT include both a Content-Length header field and a
non-identity transfer-coding. If the message does include a non-
identity transfer-coding, the Content-Length must be ignored.

## 4.4-12 MUST
Messages must not include both a Content-Length header field and a
non-identity transfer-coding. If the message does include a non-
identity transfer-coding, the Content-Length MUST be ignored.

## 4.4-13 MUST
When a Content-Length is given in a message where a message-body is
allowed, its field value MUST exactly match the number of OCTETs in
the message-body. HTTP/1.1 user agents must notify the user when an
invalid length is received and detected.

## 4.4-14 MUST
When a Content-Length is given in a message where a message-body is
allowed, its field value must exactly match the number of OCTETs in
the message-body. HTTP/1.1 user agents MUST notify the user when an
invalid length is received and detected.

# Chapter 4.5: General Header Fields
## 4.5-1
There are a few header fields which have general applicability for
both request and response messages, but which do not apply to the
entity being transferred. These header fields apply only to the
message being transmitted.

    general-header = Cache-Control            ; Section 14.9
                    | Connection               ; Section 14.10
                    | Date                     ; Section 14.18
                    | Pragma                   ; Section 14.32
                    | Trailer                  ; Section 14.40
                    | Transfer-Encoding        ; Section 14.41
                    | Upgrade                  ; Section 14.42
                    | Via                      ; Section 14.45
                    | Warning                  ; Section 14.46

General-header field names can be extended reliably only in
combination with a change in the protocol version. However, new or
experimental header fields may be given the semantics of general
header fields if all parties in the communication recognize them to
be general-header fields. Unrecognized header fields are treated as
entity-header fields.

# Chapter 5: Request
## 5-1
A request message from a client to a server includes, within the
first line of that message, the method to be applied to the resource,
the identifier of the resource, and the protocol version in use.

    Request       = Request-Line              ; Section 5.1
                    *(( general-header        ; Section 4.5
                        | request-header         ; Section 5.3
                        | entity-header ) CRLF)  ; Section 7.1
                    CRLF
                    [ message-body ]          ; Section 4.3

# Chapter 5.1: Request-Line

## 5.1-1
The Request-Line begins with a method token, followed by the
Request-URI and the protocol version, and ending with CRLF. The
elements are separated by SP characters. No CR or LF is allowed
except in the final CRLF sequence.

    Request-Line   = Method SP Request-URI SP HTTP-Version CRLF

An example
   Request-Line would be:

       GET http://www.w3.org/pub/WWW/TheProject.html HTTP/1.1

## 5.1-2
The Method token indicates the method to be performed on the
resource identified by the Request-URI. The method is case-sensitive.

    Method         = "OPTIONS"                ; Section 9.2
                    | "GET"                    ; Section 9.3
                    | "HEAD"                   ; Section 9.4
                    | "POST"                   ; Section 9.5
                    | "PUT"                    ; Section 9.6
                    | "DELETE"                 ; Section 9.7
                    | "TRACE"                  ; Section 9.8
                    | "CONNECT"                ; Section 9.9
                    | extension-method
    extension-method = token

## 5.1-3
The list of methods allowed by a resource can be specified in an
Allow header field (section 14.7). The return code of the response
always notifies the client whether a method is currently allowed on a
resource, since the set of allowed methods can change dynamically.

## 5.1-4 SHOULD
An
origin server SHOULD return the status code 405 (Method Not Allowed)
if the method is known by the origin server but not allowed for the
requested resource, and 501 (Not Implemented) if the method is
unrecognized or not implemented by the origin server.

## 5.1-5 MUST
The methods GET
and HEAD MUST be supported by all general-purpose servers. All other
methods are OPTIONAL;

## 5.1-6 MUST
The methods GET
and HEAD must be supported by all general-purpose servers. All other
methods are OPTIONAL; however, if the above methods are implemented,
they MUST be implemented with the same semantics as those specified
in section 9.

## 5.1-7
The Request-URI is a Uniform Resource Identifier (section 3.2) and
identifies the resource upon which to apply the request.

    Request-URI    = "*" | absoluteURI | abs_path | authority

## 5.1-8
The asterisk "*" means that the request does not apply to a
particular resource, but to the server itself, and is only allowed
when the method used does not necessarily apply to a resource. One
example would be

    OPTIONS * HTTP/1.1

## 5.1-9
The absoluteURI form is REQUIRED when the request is being made to a
proxy. The proxy is requested to forward the request or service it
from a valid cache, and return the response.

## 5.1-10 MAY
Note that the proxy MAY
forward the request on to another proxy or directly to the server
specified by the absoluteURI.

## 5.1-11 MUST
In order to avoid request loops, a
proxy MUST be able to recognize all of its server names, including
any aliases, local variations, and the numeric IP address.

## 5.1-12 MUST
To allow for transition to absoluteURIs in all requests in future
versions of HTTP, all HTTP/1.1 servers MUST accept the absoluteURI
form in requests, even though HTTP/1.1 clients will only generate
them in requests to proxies.

## 5.1-13
The authority form is only used by the CONNECT method (section 9.9).

## 5.1-14 MUST
The most common form of Request-URI is that used to identify a
resource on an origin server or gateway. In this case the absolute
path of the URI MUST be transmitted (see section 3.2.1, abs_path) as
the Request-URI, and the network location of the URI (authority) must
be transmitted in a Host header field.

## 5.1-15 MUST
The most common form of Request-URI is that used to identify a
resource on an origin server or gateway. In this case the absolute
path of the URI must be transmitted (see section 3.2.1, abs_path) as
the Request-URI, and the network location of the URI (authority) MUST
be transmitted in a Host header field.

## 5.1-16
For example, a client wishing
to retrieve the resource above directly from the origin server would
create a TCP connection to port 80 of the host "www.w3.org" and send
the lines:

    GET /pub/WWW/TheProject.html HTTP/1.1
    Host: www.w3.org

followed by the remainder of the Request.

## 5.1-17 MUST
Note that the absolute path
cannot be empty; if none is present in the original URI, it MUST be
given as "/" (the server root).

## 5.1-18
The Request-URI is transmitted in the format specified in section 3.2.1.

## 5.1-19 MUST
If the Request-URI is encoded using the "% HEX HEX" encoding
[42], the origin server MUST decode the Request-URI in order to
properly interpret the request.

## 5.1-20 SHOULD
Servers SHOULD respond to invalid Request-URIs with an appropriate status code.

## 5.1-21 MUST NOT
A transparent proxy MUST NOT rewrite the "abs_path" part of the
received Request-URI when forwarding it to the next inbound server,
except as noted above to replace a null abs_path with "/".

# Chapter 5.2: The Resource Identified by a Request

## 5.2-1 MAY
The exact resource identified by an Internet request is determined by
examining both the Request-URI and the Host header field.

An origin server that does not allow resources to differ by the
requested host MAY ignore the Host header field value when
determining the resource identified by an HTTP/1.1 request. (But see
section 19.6.1.1 for other requirements on Host support in HTTP/1.1.)

## 5.2-2 MUST
An origin server that does differentiate resources based on the host
requested (sometimes referred to as virtual hosts or vanity host
names) MUST use the following rules for determining the requested
resource on an HTTP/1.1 request:

## 5.2-3
1. If Request-URI is an absoluteURI, the host is part of the
Request-URI. Any Host header field value in the request MUST be
ignored.

## 5.2-4
2. If the Request-URI is not an absoluteURI, and the request includes
a Host header field, the host is determined by the Host header
field value.

## 5.2-5 @must
3. If the host as determined by rule 1 or 2 is not a valid host on
the server, the response MUST be a 400 (Bad Request) error message.

## 5.2-6 @may
Recipients of an HTTP/1.0 request that lacks a Host header field MAY
attempt to use heuristics (e.g., examination of the URI path for
something unique to a particular host) in order to determine what
exact resource is being requested.

# Chapter 5.3: Request Header Fields

## 5.3-1
The request-header fields allow the client to pass additional
information about the request, and about the client itself, to the
server. These fields act as request modifiers, with semantics
equivalent to the parameters on a programming language method
invocation.

    request-header = Accept                   ; Section 14.1
                   | Accept-Charset           ; Section 14.2
                   | Accept-Encoding          ; Section 14.3
                   | Accept-Language          ; Section 14.4
                   | Authorization            ; Section 14.8
                   | Expect                   ; Section 14.20
                   | From                     ; Section 14.22
                   | Host                     ; Section 14.23
                   | If-Match                 ; Section 14.24
                   | If-Modified-Since        ; Section 14.25
                   | If-None-Match            ; Section 14.26
                   | If-Range                 ; Section 14.27
                   | If-Unmodified-Since      ; Section 14.28
                   | Max-Forwards             ; Section 14.31
                   | Proxy-Authorization      ; Section 14.34
                   | Range                    ; Section 14.35
                   | Referer                  ; Section 14.36
                   | TE                       ; Section 14.39
                   | User-Agent               ; Section 14.43

## 5.3-2
Request-header field names can be extended reliably only in
combination with a change in the protocol version. However, new or
experimental header fields MAY be given the semantics of request-
header fields if all parties in the communication recognize them to
be request-header fields. Unrecognized header fields are treated as
entity-header fields.

# Chapter 6: Response
## 6-1
After receiving and interpreting a request message, a server responds
with an HTTP response message.

    Response      = Status-Line               ; Section 6.1
                    *(( general-header        ; Section 4.5
                    | response-header        ; Section 6.2
                    | entity-header ) CRLF)  ; Section 7.1
                    CRLF
                    [ message-body ]          ; Section 7.2

# Chapter 6.1: Status-Line

## 6.1-1
The first line of a Response message is the Status-Line, consisting
of the protocol version followed by a numeric status code and its
associated textual phrase, with each element separated by SP
characters. No CR or LF is allowed except in the final CRLF sequence.

    Status-Line = HTTP-Version SP Status-Code SP Reason-Phrase CRLF

## 6.1-2
The Status-Code element is a 3-digit integer result code of the
attempt to understand and satisfy the request. These codes are fully
defined in section 10.

## 6.1-3
The Reason-Phrase is intended to give a short
textual description of the Status-Code. The Status-Code is intended
for use by automata and the Reason-Phrase is intended for the human
user. The client is not required to examine or display the Reason-
Phrase.

## 6.1-4
The first digit of the Status-Code defines the class of response. The
last two digits do not have any categorization role. There are 5
values for the first digit:

    - 1xx: Informational - Request received, continuing process

    - 2xx: Success - The action was successfully received,
    understood, and accepted

    - 3xx: Redirection - Further action must be taken in order to
    complete the request

    - 4xx: Client Error - The request contains bad syntax or cannot
    be fulfilled

    - 5xx: Server Error - The server failed to fulfill an apparently
    valid request

## 6.1-5
The individual values of the numeric status codes defined for
HTTP/1.1, and an example set of corresponding Reason-Phrase's, are
presented below. The reason phrases listed here are only
recommendations -- they MAY be replaced by local equivalents without
affecting the protocol.

    Status-Code    =
        "100"  ; Section 10.1.1: Continue
        | "101"  ; Section 10.1.2: Switching Protocols
        | "200"  ; Section 10.2.1: OK
        | "201"  ; Section 10.2.2: Created
        | "202"  ; Section 10.2.3: Accepted
        | "203"  ; Section 10.2.4: Non-Authoritative Information
        | "204"  ; Section 10.2.5: No Content
        | "205"  ; Section 10.2.6: Reset Content
        | "206"  ; Section 10.2.7: Partial Content
        | "300"  ; Section 10.3.1: Multiple Choices
        | "301"  ; Section 10.3.2: Moved Permanently
        | "302"  ; Section 10.3.3: Found
        | "303"  ; Section 10.3.4: See Other
        | "304"  ; Section 10.3.5: Not Modified
        | "305"  ; Section 10.3.6: Use Proxy
        | "307"  ; Section 10.3.8: Temporary Redirect
        | "400"  ; Section 10.4.1: Bad Request
        | "401"  ; Section 10.4.2: Unauthorized
        | "402"  ; Section 10.4.3: Payment Required
        | "403"  ; Section 10.4.4: Forbidden
        | "404"  ; Section 10.4.5: Not Found
        | "405"  ; Section 10.4.6: Method Not Allowed
        | "406"  ; Section 10.4.7: Not Acceptable
        | "407"  ; Section 10.4.8: Proxy Authentication Required
        | "408"  ; Section 10.4.9: Request Time-out
        | "409"  ; Section 10.4.10: Conflict
        | "410"  ; Section 10.4.11: Gone
        | "411"  ; Section 10.4.12: Length Required
        | "412"  ; Section 10.4.13: Precondition Failed
        | "413"  ; Section 10.4.14: Request Entity Too Large
        | "414"  ; Section 10.4.15: Request-URI Too Large
        | "415"  ; Section 10.4.16: Unsupported Media Type
        | "416"  ; Section 10.4.17: Requested range not satisfiable
        | "417"  ; Section 10.4.18: Expectation Failed
        | "500"  ; Section 10.5.1: Internal Server Error
        | "501"  ; Section 10.5.2: Not Implemented
        | "502"  ; Section 10.5.3: Bad Gateway
        | "503"  ; Section 10.5.4: Service Unavailable
        | "504"  ; Section 10.5.5: Gateway Time-out
        | "505"  ; Section 10.5.6: HTTP Version not supported
        | extension-code

    extension-code = 3DIGIT
    Reason-Phrase  = *<TEXT, excluding CR, LF>

## 6.1-6 MUST
HTTP status codes are extensible. HTTP applications are not required
to understand the meaning of all registered status codes, though such
understanding is obviously desirable. However, applications MUST
understand the class of any status code, as indicated by the first
digit, and treat any unrecognized response as being equivalent to the
x00 status code of that class, with the exception that an
unrecognized response must not be cached.

## 6.1-7 MUST NOT
HTTP status codes are extensible. HTTP applications are not required
to understand the meaning of all registered status codes, though such
understanding is obviously desirable. However, applications must
understand the class of any status code, as indicated by the first
digit, and treat any unrecognized response as being equivalent to the
x00 status code of that class, with the exception that an
unrecognized response MUST NOT be cached.

## 6.1-8
For example, if an
unrecognized status code of 431 is received by the client, it can
safely assume that there was something wrong with its request and
treat the response as if it had received a 400 status code. In such
cases, user agents SHOULD present to the user the entity returned
with the response, since that entity is likely to include human-
readable information which will explain the unusual status.

# Chapter 6.2: Response Header Fields
## 6.2-1
The response-header fields allow the server to pass additional
information about the response which cannot be placed in the Status-
Line. These header fields give information about the server and about
further access to the resource identified by the Request-URI.

    response-header = Accept-Ranges           ; Section 14.5
                    | Age                     ; Section 14.6
                    | ETag                    ; Section 14.19
                    | Location                ; Section 14.30
                    | Proxy-Authenticate      ; Section 14.33
                    | Retry-After             ; Section 14.37
                    | Server                  ; Section 14.38
                    | Vary                    ; Section 14.44
                    | WWW-Authenticate        ; Section 14.47

## 6.2-2
Response-header field names can be extended reliably only in
combination with a change in the protocol version. However, new or
experimental header fields MAY be given the semantics of response-
header fields if all parties in the communication recognize them to
be response-header fields.

## 6.2-3
Unrecognized header fields are treated as entity-header fields.

# Chapter 10.1: Informational 1xx

## 10.1-1
This class of status code indicates a provisional response,
consisting only of the Status-Line and optional headers, and is
terminated by an empty line.

## 10.1-2
There are no required headers for this class of status code.

## 10.1-3
Since HTTP/1.0 did not define any 1xx status
codes, servers MUST NOT send a 1xx response to an HTTP/1.0 client
except under experimental conditions.

## 10.1-4
A client MUST be prepared to accept one or more 1xx status responses
prior to a regular response, even if the client does not expect a 100
(Continue) status message.

## 10.1-5
Unexpected 1xx status responses MAY be ignored by a user agent.

## 10.1-6
Proxies MUST forward 1xx responses, unless the connection between the
proxy and its client has been closed, or unless the proxy itself
requested the generation of the 1xx response.

## 10.1.1-1
The client SHOULD continue with its request.

## 10.1.1-2
The client SHOULD continue by sending the remainder of the request or, if the
request has already been completed, ignore this response.

## 10.1.1-3
The server MUST send a final response after the request has been completed.

## 10.1.2-1
The server will switch protocols to those defined by the response's
Upgrade header field immediately after the empty line which
terminates the 101 response.

## 10.1.2-2
The protocol SHOULD be switched only when it is advantageous to do so.

# Chapter 14.10: Connection

## 14.10-1
The Connection general-header field allows the sender to specify
options that are desired for that particular connection

## 14.10-2
The Connection general-header field allows the sender to specify
options that are desired for that particular connection and MUST NOT
be communicated by proxies over further connections.

## 14.10-3
The Connection header has the following grammar:

    Connection = "Connection" ":" 1#(connection-token)
    connection-token  = token

## 14.10-4
HTTP/1.1 proxies MUST parse the Connection header field before a
message is forwarded and, for each connection-token in this field,
remove any header field(s) from the message with the same name as the
connection-token.

## 14.10-5
Connection options are signaled by the presence of
a connection-token in the Connection header field, not by any
corresponding additional header field(s), since the additional header
field may not be sent if there are no parameters associated with that
connection option.

## 14.10-6
Message headers listed in the Connection header MUST NOT include
end-to-end headers, such as Cache-Control.

## 14.10-7
HTTP/1.1 defines the "close" connection option for the sender to
signal that the connection will be closed after completion of the
response. For example,

    Connection: close

in either the request or the response header fields indicates that
the connection SHOULD NOT be considered `persistent' (section 8.1)
after the current request/response is complete.

## 14.10-8
HTTP/1.1 applications that do not support persistent connections MUST
include the "close" connection option in every message.

## 14.10-9
A system receiving an HTTP/1.0 (or lower-version) message that
includes a Connection header MUST, for each connection-token in this
field, remove and ignore any header field(s) from the message with
the same name as the connection-token. This protects against mistaken
forwarding of such header fields by pre-HTTP/1.1 proxies.

# Chapter 14.18: Date

## 14.18-1
The Date general-header field represents the date and time at which
the message was originated, having the same semantics as orig-date in
RFC 822. The field value is an HTTP-date, as described in section
3.3.1; it MUST be sent in RFC 1123 [8]-date format.

    Date  = "Date" ":" HTTP-date

An example is

    Date: Tue, 15 Nov 1994 08:12:31 GMT

## 14.18-2
Origin servers MUST include a Date header field in all responses,
except in these cases:

## 14.18-3
1. If the response status code is 100 (Continue) or 101 (Switching
    Protocols), the response MAY include a Date header field, at
    the server's option.

## 14.18-4
2. If the response status code conveys a server error, e.g. 500
    (Internal Server Error) or 503 (Service Unavailable), and it is
    inconvenient or impossible to generate a valid Date.

## 14.18-5
3. If the server does not have a clock that can provide a
    reasonable approximation of the current time, its responses
    MUST NOT include a Date header field. In this case, the rules
    in section 14.18.1 MUST be followed.

## 14.18-6
A received message that does not have a Date header field MUST be
assigned one by the recipient if the message will be cached by that
recipient or gatewayed via a protocol which requires a Date.

## 14.18-7
An HTTP implementation without a clock MUST NOT cache responses without
revalidating them on every use.

## 14.18-8
An HTTP cache, especially a shared
cache, SHOULD use a mechanism, such as NTP [28], to synchronize its
clock with a reliable external standard.

## 14.18-9
Clients SHOULD only send a Date header field in messages that include
an entity-body, as in the case of the PUT and POST requests, and even
then it is optional.

## 14.18-10
A client without a clock MUST NOT send a Date
header field in a request.

## 14.18-11
The HTTP-date sent in a Date header SHOULD NOT represent a date and
time subsequent to the generation of the message.

## 14.18-12
It SHOULD represent
the best available approximation of the date and time of message
generation, unless the implementation has no means of generating a
reasonably accurate date and time.

## 14.18-13
Some origin server implementations might not have a clock available.
An origin server without a clock MUST NOT assign Expires or Last-
Modified values to a response, unless these values were associated
with the resource by a system or user with a reliable clock.

## 14.18-14
It MAY
assign an Expires value that is known, at or before server
configuration time, to be in the past (this allows "pre-expiration"
of responses without storing separate Expires values for each
resource).

# Chapter 14.23: Host

## 14.23-1
The Host field value MUST represent
the naming authority of the origin server or gateway given by the
original URL. This allows the origin server or gateway to
differentiate between internally-ambiguous URLs, such as the root "/"
URL of a server for multiple host names on a single IP address.

## 14.23-2
    Host = "Host" ":" host [ ":" port ] ; Section 3.2.2

A "host" without any trailing port information implies the default
port for the service requested (e.g., "80" for an HTTP URL).

## 14.23-3
A client MUST include a Host header field in all HTTP/1.1 request messages.

## 14.23-4
If the requested URI does not include an Internet host
name for the service being requested, then the Host header field MUST
be given with an empty value.

## 14.23-5
An HTTP/1.1 proxy MUST ensure that any
request message it forwards does contain an appropriate Host header
field that identifies the service being requested by the proxy.

## 14.23-6
All Internet-based HTTP/1.1 servers MUST respond with a 400 (Bad Request)
status code to any HTTP/1.1 request message which lacks a Host header
field.

# Chapter 14.38: Server

## 14.38-1
The field
can contain multiple product tokens (section 3.8) and comments
identifying the server and any significant subproducts. The product
tokens are listed in order of their significance for identifying the
application.

## 14.38-2
    Server         = "Server" ":" 1*( product | comment )

Example:

    Server: CERN/3.0 libwww/2.17

## 14.38-3
If the response is being forwarded through a proxy, the proxy
application MUST NOT modify the Server response-header.

## 14.38-4
Instead, it
SHOULD include a Via field (as described in section 14.45).

# Chapter 14.42: Upgrade

## 14.42-1
The server
MUST use the Upgrade header field within a 101 (Switching Protocols)
response to indicate which protocol(s) are being switched.

## 14.42-2
Grammar

    Upgrade        = "Upgrade" ":" 1#product

For example,

    Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11

## 14.42-3
The Upgrade header field only applies to switching application-layer
protocols upon the existing transport-layer connection. Upgrade
cannot be used to insist on a protocol change; its acceptance and use
by the server is optional.

## 14.42-4
The capabilities and nature of the
application-layer communication after the protocol change is entirely
dependent upon the new protocol chosen, although the first action
after changing the protocol MUST be a response to the initial HTTP
request containing the Upgrade header field.

## 14.42-5
The Upgrade header field only applies to the immediate connection.
Therefore, the upgrade keyword MUST be supplied within a Connection
header field (section 14.10) whenever Upgrade is present in an
HTTP/1.1 message.

## 14.42-6
This specification only defines the protocol name "HTTP" for use by
the family of Hypertext Transfer Protocols, as defined by the HTTP
version rules of section 3.1 and future updates to this
specification. Any token can be used as a protocol name; however, it
will only be useful if both the client and server associate the name
with the same protocol.

# Chapter 14.43: User-Agent

## 14.43-1
User agents SHOULD include this field with
requests.

## 14.43-2
The field can contain multiple product tokens (section 3.8)
and comments identifying the agent and any subproducts which form a
significant part of the user agent.

## 14.43-3
By convention, the product tokens
are listed in order of their significance for identifying the
application.

## 14.43-4
Grammar
    User-Agent     = "User-Agent" ":" 1*( product | comment )

Example:

    User-Agent: CERN-LineMode/2.15 libwww/2.17b3

# Chapter 15.3: DNS Spoofing

## 15.3-1
Clients using HTTP rely heavily on the Domain Name Service, and are
thus generally prone to security attacks based on the deliberate
mis-association of IP addresses and DNS names. Clients need to be
cautious in assuming the continuing validity of an IP number/DNS name
association.

In particular, HTTP clients SHOULD rely on their name resolver for
confirmation of an IP number/DNS name association, rather than
caching the result of previous host name lookups.

## 15.3-2
Many platforms
already can cache host name lookups locally when appropriate, and
they SHOULD be configured to do so.

## 15.3-3
If HTTP clients cache the results of host name lookups in order to
achieve a performance improvement, they MUST observe the TTL
information reported by DNS.
