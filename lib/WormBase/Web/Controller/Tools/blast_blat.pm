package WormBase::Web::Controller::Tools::blast_blat;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

sub index :Path Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'tools/blast_blat/index.tt2';

    my $api = $c->model('WormBaseAPI')->_tools->{blast_blat};
    $c->stash->{blast_databases} = $api->blast_databases;
    $c->stash->{blat_databases} = $api->blat_databases;
}



=pod

AQL run() method by example.
Run provided by API::Service::blast_blat.

sub run :Path('run') :Args(0) {
    my ($self, $c) = @_;
    my $params = $c->req->params;
    my $stash  = $c->stash;

    $stash->{result_type} = $params->{'result-type'};
    $stash->{query_type}  = $params->{'query-type'} || 'AQL';
    $stash->{query}       = $params->{'ql-query'};

    unless ($params->{'ql-query'}) {
        $stash->{error} = 'No query. Please enter a query';
        $c->detach;
    }

    my $api = $c->model('WormBaseAPI')->_tools->{blast_blat};
    $stash->{blast_databases} = $api->blast_databases;

    my $data = $params->{'query-type'} eq 'AQL'
             ? $qlserv->aql($params->{'ql-query'})
             : $qlserv->wql($params->{'ql-query'},
                            $params->{'result-type'} ne 'HTML');

    if ($params->{'result-type'} eq 'HTML') {
        if ($params->{'query-type'} eq 'AQL') {
            $qlserv->objs2pack($data);
        }
        $stash->{template} = 'tools/aql_wql/index.tt2';
        $stash->{data} = $data;
    }
    else {
        my $text = $qlserv->objs2text($data);
        open my $fh, '<', \$text;

        $c->res->content_type('text/plain');
        $c->res->body($fh);
        # is the above significantly faster than the following?
        # $c->res->body($qlserv->objs2text($data);
        $c->detach;
    }
}

=cut


sub end :Private {
    my ($self, $c) = @_;
    $c->forward('/end') if $c->res->content_type ne 'text/plain';
    # do nothing for plain text.
}

__PACKAGE__->meta->make_immutable;

1;
