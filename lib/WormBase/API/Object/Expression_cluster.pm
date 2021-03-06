package WormBase::API::Object::Expression_cluster;
use Moose;

with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Expr_pattern';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Expression_cluster

=head1 SYNPOSIS

Model for the Ace ?Expression_cluster class.

=head1 URL

http://wormbase.org/species/*/expresssion_cluster

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
# The Overview widget
#
#######################################

# name { }
# Supplied by Role

# description { }
# Supplied by Role

# remarks {}
# Supplied by Role

# algorithm { }
# This method will return a data structure with algorithm used to define the expression_cluster.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/algorithm

sub algorithm {
    my $self   = shift;
    my $object = $self->object;
    my $algorithm =  $object->Algorithm;
    return { description => 'Algorithm used to determine cluster',
	     data        => $algorithm && "$algorithm",
    };
}

sub attribute_of {
    my $self = shift;
    my $object = $self->object;
    my @attribute_of = $object->Attribute_of;
    my %data;

    foreach my $ao ($object->Attribute_of) {
        my @items = map { $self->_pack_obj($_) } $object->$ao;
        $data{"$ao"} = @items ? \@items : undef;
    }

    return {
        description => "Items attributed to this expression cluster",
        data => %data ? \%data : undef,
    }
}

#######################################
#
# The Genes widget
#
#######################################

# genes { }
# This method will return a data structure 
# with genes contained in the expression cluster.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/genes

sub genes {
    my $self   = shift;
    my $object = $self->object;
    my @data = map {$self->_pack_obj($_)} $object->Gene;
    return { data        => @data ? \@data : undef,
	     description => 'genes contained in this expression cluster' };

}


#######################################
#
# The Associations widget
#
#######################################

# anatomy_terms { }
# This method will return a data structure with anatomy 
# ontology terms associated with the expression cluster.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/anatomy_terms

sub anatomy_terms {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    foreach ($object->Anatomy_term) {
        my $definition   = $_->Definition;
        push @data, {
            anatomy_term => $self->_pack_obj($_),
            definition => $definition && "$definition",
        };
    }
    return { data        => @data ? \@data : undef,
             description => 'anatomy terms associated with this expression cluster'
    };
}

sub life_stages {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    foreach ($object->Life_stage) {
        my $definition   = $_->Definition;
        push @data, {
            life_stages => $self->_pack_obj($_),
            definition => $definition && "$definition",
        };
    }
    return { data        => @data ? \@data : undef,
             description => 'Life stages associated with this expression cluster'
    };
}

sub go_terms {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    foreach ($object->GO_term) {
        my $definition   = $_->Definition;
        push @data, {
            go_terms => $self->_pack_obj($_),
            definition => $definition && "$definition",
        };
    }
    return { data        => @data ? \@data : undef,
             description => 'GO terms associated with this expression cluster'
    };
}

sub processes {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    foreach ($object->WBProcess) {
        my $definition   = $_->Summary;
        push @data, {
            processes => $self->_pack_obj($_),
            definition => $definition && "$definition",
        };
    }
    return { data        => @data ? \@data : undef,
             description => 'Processes associated with this expression cluster'
    };
}


#######################################
#
# The Clustered Data widget
#
#######################################

# microarray { }
# This method will return a data structure with 
# microarray results from the expression cluster.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/microarray

sub microarray {
    my $self        = shift;
    my $object      = $self->object;

    my @data;      
    foreach ($object->Microarray_results) {
    	my $experiment = $self->_pack_obj($_->Result) if $_->Result;
    	my $minimum = $_->Min;
    	my $maximum = $_->Max;
    	
	push @data, {
	    microarray => $self->_pack_obj($_),
	    experiment => $experiment,
	    minimum => $minimum && "$minimum",
	    maximum => $maximum && "$maximum",
	};
    }
    return { data        => @data ? \@data : undef,
	     description => 'microarray results from expression cluster'
    };
}


# sage_tags { }
# This method will return a data structure with 
# sage tags analyzing the expression_cluster.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/sage_tags

sub sage_tags {
    my $self   = shift;
    my $object = $self->object;
    my @data   = map {$self->_pack_obj($_)} $object->SAGE_tag;
    return { data        => @data ? \@data : undef,
	     description => 'Sage tags associated with this expression_cluster'
    };
}

#######################################
#
# The Regulation widget
#
#######################################

sub regulated_by_gene {
    my $self = shift;
    my $object = $self->object;
    my @data = map {$self->_pack_obj($_)} $object->Regulated_by_gene;
    return {
        description => "Gene regulating this expression cluster",
        data => @data ? \@data : undef
    }
}

sub regulated_by_treatment {
    my $self = shift;
    my $object = $self->object;
    my $treatment = $object->Regulated_by_treatment;
    return {
        description => "Treatment regulating this expression cluster",
        data => $treatment && "$treatment"
    }
}

sub regulated_by_molecule {
    my $self = shift;
    my $object = $self->object;
    my @data = map {$self->_pack_obj($_)} $object->Regulated_by_molecule;
    return {
        description => "Molecule regulating this expression cluster",
        data => @data ? \@data : undef
    }
}


#######################################
#
# The References widget
#
#######################################

# references {}
# Supplied by Role

__PACKAGE__->meta->make_immutable;

1;

