#!/usr/bin/perl -w

# cpan install HTML::WikiConverter::Markdown

use HTML::WikiConverter;
my $wc = new HTML::WikiConverter( dialect => 'Markdown' );
print $wc->html2wiki( uri => "file://$ARGV[0]" ), "\n\n";
