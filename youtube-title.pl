#!/usr/bin/env perl
use Purple;

use strict;
use warnings;

use JSON qw(decode_json);
use LWP::Simple qw(get);

# Main URL: https://github.com/Eckankar/YouTubeTitleAdderPidgin
#
# Changelog:
#
# 1.0 (2013-01-30)
# Initial version

our %PLUGIN_INFO = (
    perl_api_version => 2,
    name             => "YouTube Title Adder",
    version          => "1.0",
    summary          => "Shows titles on YouTube links",
    description      => "Shows titles on YouTube links",
    author           => "Sebastian Paaske Tørholm",
    url              => "http://mathemaniac.org",

    load             => "plugin_load",
    unload           => "plugin_unload",
);

sub debug {
    my $msg = shift;
    Purple::Debug::info("youtube-title", "$msg\n");
}

sub plugin_init {
    return %PLUGIN_INFO;
}

sub plugin_load {
    my $plugin = shift;

    my $conversations = Purple::Conversations::get_handle();

    Purple::Signal::connect($conversations, "receiving-im-msg", $plugin,
                            \&receiving_im_msg, 0);

    debug("Plugin loaded");
}

sub plugin_unload {
    my $plugin = shift;
    debug("Plugin unloaded");
}

sub receiving_im_msg {
    my ($account, $who, $msg) = @_;

    if ($msg =~ /(?: youtube\.com\/watch\?.*v=
                   | youtu\.be\/
                   | y2u\.be\/)
                                ([-_A-Za-z0-9]{11})/ix) {
        my $videoid = $1;

        my $url = "http://gdata.youtube.com/feeds/api/videos/$videoid?alt=json";
        my $json = get($url);

        my $gdata = decode_json($json);
        my $title = $gdata->{entry}->{title}->{'$t'};

        $_[2] .= " (YT: $title)";
    }
}
