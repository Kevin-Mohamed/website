package WormBase::API::Object::Species;

use Moose;
use File::Spec;
use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

# TODO:
#  Split _build_description (see comment down below)
#  Movie method?

=pod

=head1 NAME

WormBase::API::Object::Species

=head1 SYNPOSIS

Model for the Ace ?Species class.

=head1 URL

http://wormbase.org/species/*

=cut


#######################################
#
# CLASS METHODS
#
#######################################

#######################################
#
# INSTANCE METHODS
#
#######################################

#######################################
#
# The Genome Assemblies widget
#
#######################################

# name { }
# Supplied by Role

# description {}
# Supplied by Role

# remarks {}
# Supplied by Role

# current_assemblies { }
# This method will return data for a datatable containing details
# on the most current assemblies for this species
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/species/Caenorhabditis elegans/current_assemblies

sub current_assemblies {
    my $self   = shift;

    # Multiple assemblies for a given species are 
    # represented by linking from the live Sequence_collection
    # to others.
    my $data = $self->_get_assemblies('current');  
    return {
	description => "current genomic assemblies",
	data => @$data ? $data : undef
    }
}

# previous_assemblies { }
# This method will return data for a datatable containing details
# on the previous or replaced assemblies for this species
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/species/Caenorhabditis elegans/previous_assemblies

sub previous_assemblies {
    my $self   = shift;

    # Multiple assemblies for a given species are 
    # represented by linking from the live Sequence_collection
    # to others.
    my $data = $self->_get_assemblies('previous');  
    return {
	description => "previous genomic assemblies",
	data => @$data ? $data : undef
    }
}

sub _get_assemblies {
    my ($self,$type) = @_;
    my $object = $self->object;    

    my @assemblies = $object->Assembly;
    my @data;
    foreach (@assemblies) {
	next if $_->Status eq 'Dead' || $_->Status eq 'Suppressed';

	# Starting from live and working backwards.
	if (($type eq 'previous') && ($_->Supercedes)) {
	    push @assemblies,$_->Supercedes;
	}

	push @data,$self->_process_assembly($_)
	   unless ($_->Status eq 'Live' && $type eq 'previous');

    }
    
    return \@data;   
}


sub _process_assembly {    
    my ($self,$assembly) = @_;

    my $ref    = $assembly->Evidence ? $assembly->Evidence->right : $assembly->Laboratory;
    my $label  = $assembly->Name || "$assembly";

    my $superceded_by = $assembly->Superceded_by ? $assembly->Superceded_by : '-';
    my $status        = $superceded_by ? 'superceded' : 'current';

    my $wb_range      = 
	"WS" . $assembly->First_WS_release . ' - '
	. ($assembly->Superceded_by ? "WS" . $assembly->Latest_WS_release : ''); 
	
    my $data = { name => $self->_pack_obj($assembly->Name, "$label", coord => { start => 1 }),
		 sequenced_strain  => $self->_pack_obj($assembly->Strain),
		 first_wb_release  => "WS" . $assembly->First_WS_release,
		 latest_wb_release => "WS" . $assembly->Latest_WS_release,
		 wb_release_range  => $wb_range,
		 reference         => $self->_pack_obj($ref),
		 status            => $status,
		 xrefs             => $self->_get_xrefs($assembly),
    };
    return $data;
}


sub _get_xrefs {
    my ($self,$object) = @_;

    my @databases = $object->Database;
    my %dbs;

    foreach my $db (@databases) {
	$dbs{xrefs}{"$db"}{name} = "$db";
	foreach my $key ($db->col) {
	    my @types = $key->col;	    
	    my %types;
	    foreach my $val (@types) {
		$types{$key} = "$val";
		$dbs{xrefs}{"$db"}{"$key"} = "$val";
	    }
	}
    }
    return \%dbs;
}


# ncbi_id { }
# This method will return the NCBI taxonomy ID for this species
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/species/Caenorhabditis elegans/ncbi_id

sub ncbi_id {
    my $self   = shift;
    my $object = $self->object;

    my $ncbi_id = $object->NCBITaxonomyID;
    return {
      description => "NCBI taxonomy id for the species",
      data => "$ncbi_id" || undef
    }
}



############################################################
#
# PRIVATE METHODS
#
############################################################

__PACKAGE__->meta->make_immutable;

1;

