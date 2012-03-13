package WormBase::API::Object::Operon;
use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';
=pod 

=head1 NAME

WormBase::API::Object::Operon

=head1 SYNPOSIS

Model for the Ace ?Operon class.

=head1 URL

http://wormbase.org/species/operon

=cut

has 'tracks' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return {
            description => 'tracks displayed in GBrowse',
            data        => [qw/CG OP/],
        };
    }
);

has 'gff' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
        my ($self) = @_;
        return $self->gff_dsn;
    }
   );

#######################################
#
# CLASS METHODS
#
#######################################

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut

#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub remarks { }
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>




=head3 species

This method will return a data structure with species containing the operon.

=over

=item PERL API

 $data = $model->species();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Operon id (eg CEOP1140)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/species

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub species {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->Species;
    my $data_pack  = $self->_pack_obj($tag_object);
    return {
        'data'        => $data_pack,
        'description' => 'species containing the operon'
    };
}

=head3 structure

This method will return a data structure with structure of the operon.

=over

=item PERL API

 $data = $model->structure();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Operon id (eg CEOP1140)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/structure

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub structure {
    my $self   = shift;
    my $operon = $self->object;
    my @data;

    foreach my $gene ($operon->Contains_gene) {
        my @spliced = map {text => $self->_pack_obj($_), evidence => $self->_get_evidence($_)}, $gene->col;
        push @data,
          {
            gene_info   => $self->_pack_obj($gene),
            splice_info => @spliced ? \@spliced : undef,
          };
    }
    return {
        'data'        => @data ? \@data : undef,
        'description' => 'structure information for this operon'
    };
}

#########################
#
# Internal Methods
#
##########################

sub _build__segments {
    my $self = shift;
    my $object = $self->object;
    my $class = $object->class;
    return [ $self->gff_dsn->segment($class => $object) // () ];
}

=pod replace by the standard evidence method _get_evidence
sub _get_evidence_names {
	my $self = shift;
    my $evidences = shift;
    my @ret;

    foreach my $ev (@$evidences) {
        my @names = $ev->col;
        if (   $ev eq "Person_evidence"
            || $ev eq "Author_evidence"
            || $ev eq "Curator_confirmed" )
        {
            $ev =~ /(.*)_(evidence|confirmed)/;   #find a better way to do this?
            @names = map { $1 . ': ' . $_->Full_name || $_ } @names;
        }
        elsif ( $ev eq "Paper_evidence" ) {
            @names = map { 'Paper: ' . $_->Brief_citation || $_ } @names;
        }
        elsif ( $ev eq "Feature_evidence" ) {
            @names = map { 'Feature: ' . $_->Visible->right || $_ } @names;
        }
        elsif ( $ev eq "From_analysis" ) {
            @names = map { 'Analysis: ' . $_->Description || $_ } @names;
        }
        else {
            @names = map { $ev . ': ' . $_ } @names;
        }
        push( @ret, @names );
    }
    return @ret;
}
=cut

__PACKAGE__->meta->make_immutable;

1;

