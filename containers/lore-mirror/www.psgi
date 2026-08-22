# PSGI wrapper for public-inbox-httpd (trimmed from public-inbox's
# examples/public-inbox.psgi). The daemon serves plain HTTP behind
# TLS-terminating proxies (istio gateway, itself behind cloudflared), so
# without ReverseProxy honoring X-Forwarded-Proto every absolute URL the
# WWW code generates (redirects, Atom feeds, mirror instructions) says
# http://.
use strict;
use warnings;
use PublicInbox::WWW;
use Plack::Builder;
my $www = PublicInbox::WWW->new;
$www->preload;

builder {
	enable 'ReverseProxy';
	enable 'Head';
	sub { $www->call($_[0]) };
}
