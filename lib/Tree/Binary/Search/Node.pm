
package Tree::Binary::Search::Node;

use strict;
use warnings;

use Tree::Binary;

our $VERSION = '0.03';

our @ISA = qw(Tree::Binary);

## ----------------------------------------------------------------------------
## Tree::Binary::Search
## ----------------------------------------------------------------------------

### constructor

sub new {
	my ($_class, $node_key, $node_value) = @_;
	my $class = ref($_class) || $_class;
	my $binary_search_tree = {};
	bless($binary_search_tree, $class);
	$binary_search_tree->_init($node_key, $node_value);
	return $binary_search_tree;
}

### ---------------------------------------------------------------------------
### methods
### ---------------------------------------------------------------------------

## ----------------------------------------------------------------------------
## private methods

sub _init {
	my ($self, $node_key, $node_value) = @_;
    (defined($node_key)) || die "Insufficient Arguments : you must provide a node key";    
	# set the value of the node key
    $self->{_node_key} = $node_key;
    $self->SUPER::_init($node_value);
}

## ----------------------------------------------------------------------------
## accessors

# this value is read-only, to change it 
# would compromise the entire data-structure
sub getNodeKey {
	my ($self) = @_;
	return $self->{_node_key};
}

## ----------------------------------------------------------------------------
## mutator

sub makeRoot {
    my ($self) = @_;
    $self->{_parent} = undef;   
    unless ($self->isLeaf()) {
        $self->fixDepth();
    }
    else {
        $self->{_depth} = 0; 
    }
}

## ----------------------------------------------------------------------------
## cloning 

sub clone {
    my ($self) = @_;
    my $clone = $self->SUPER::clone();
    # we just do a copy here, even though
    # a key can theoretically be an object
    # if you want to actually clone it, you
    # will have to do it yourself
    $clone->{_node_key} = $self->{_node_key};  
    return $clone;
}

# NOTE:
# cloneShallow will copy _node_key by default
# because it just copies the internal hash by
# deferencing it.

1;

__END__

=head1 NAME

Tree::Binary::Search::Node - A node for a Tree::Binary::Search tree

=head1 SYNOPSIS

  use Tree::Binary::Search::Node;

=head1 DESCRIPTION

This is a subclass of Tree::Binary and is mostly used by Tree::Binary::Search. 

=head1 METHODS

=over 4

=item B<new ($node_key, $node_value)>

The constructor takes a C<$node_key> and a C<$node_value>. The key is used by Tree::Binary::Search to order the nodes in the tree. Both arguments are required, and exception is thrown if they are not present.

=item B<getNodeKey>

Returns the node key as set in the constructor. Node keys are write-once-read-only values, if you could change the node key, it would mess up the entire search tree.

=item B<makeRoot>

This is used by Tree::Binary::Search when it need to re-root a tree due to a deletion.

=item B<clone>

Makes sure that the node key is cloned as well. 

=back

=head1 TO DO

=over 4

=item Reference node keys

Right now, there is nothing preventing you from using anything you want as a node key as long as you create the proper comparison function in Tree::Binary::Search. I would like to test this more, and possibly write some code to faciliate it.

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

See the CODE COVERAGE section of Tree::Binary for details.

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

