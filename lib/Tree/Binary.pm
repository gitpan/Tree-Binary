
package Tree::Binary;

use strict;
use warnings;

our $VERSION = '0.04';

## ----------------------------------------------------------------------------
## Tree::Binary
## ----------------------------------------------------------------------------

### constructor

sub new {
	my ($_class, $node) = @_;
	my $class = ref($_class) || $_class;
	my $binary_tree = {};
	bless($binary_tree, $class);
	$binary_tree->_init($node);
	return $binary_tree;
}

### ---------------------------------------------------------------------------
### methods
### ---------------------------------------------------------------------------

## ----------------------------------------------------------------------------
## private methods

sub _init {
	my ($self, $node) = @_;
    (defined($node)) || die "Insufficient Arguments : you must provide a node value";
    # set the value of the unique id
    ($self->{_uid}) = ("$self" =~ /\((.*?)\)$/);    
	# set the value of the node
	$self->{_node}   = $node;
    # create the child nodes
    $self->{_left}   = undef;
    $self->{_right}  = undef;
    # initialize the parent and depth here
    $self->{_parent} = undef;
    $self->{_depth}  = 0;    
}

## ----------------------------------------------------------------------------
## mutators

sub setNodeValue {
	my ($self, $node_value) = @_;
	(defined($node_value)) || die "Insufficient Arguments : must supply a value for node";
	$self->{_node} = $node_value;
}

sub setUID {
    my ($self, $uid) = @_;
    ($uid) || die "Insufficient Arguments : Custom Unique ID's must be a true value";
    $self->{_uid} = $uid;
}

sub setLeft {
    my ($self, $tree) = @_;
    (defined($tree) && ref($tree) && UNIVERSAL::isa($tree, "Tree::Binary"))
        || die "Insufficient Arguments : left argument must be a Tree::Binary object";   
	$tree->{_parent} = $self;
    $self->{_left} = $tree;
    unless ($tree->isLeaf()) {
        $tree->fixDepth();
    }
    else {
        $tree->{_depth} = $self->getDepth() + 1; 
    }
    $self;
}

sub removeLeft {
    my ($self) = @_;
    ($self->hasLeft()) || die "Illegal Operation: cannot remove node that doesnt exist";    
    my $left = $self->{_left};
    $left->{_parent} = undef;   
    unless ($left->isLeaf()) {
        $left->fixDepth();
    }
    else {
        $left->{_depth} = 0; 
    }
    $self->{_left} = undef;     
    return $left;
}

sub setRight {
    my ($self, $tree) = @_;
    (defined($tree) && ref($tree) && UNIVERSAL::isa($tree, "Tree::Binary"))
        || die "Insufficient Arguments : right argument must be a Tree::Binary object";        
	$tree->{_parent} = $self;
    $self->{_right} = $tree;    
    unless ($tree->isLeaf()) {
        $tree->fixDepth();
    }
    else {
        $tree->{_depth} = $self->getDepth() + 1; 
    }         
    $self;
}

sub removeRight {
    my ($self) = @_;
    ($self->hasRight()) || die "Illegal Operation: cannot remove node that doesnt exist";
    my $right = $self->{_right};
    $right->{_parent} = undef;
    unless ($right->isLeaf()) {
        $right->fixDepth();
    }
    else {
        $right->{_depth} = 0; 
    }
    $self->{_right} = undef;    
    return $right;
}

## ----------------------------------------------------------------------------
## accessors

sub getUID {
    my ($self) = @_;
    return $self->{_uid};
}

sub getParent {
	my ($self)= @_;
	return $self->{_parent};
}

sub getDepth {
	my ($self) = @_;
	return $self->{_depth};
}

sub getNodeValue {
	my ($self) = @_;
	return $self->{_node};
}

sub getLeft {
    my ($self) = @_;
    return $self->{_left};
}

sub getRight {
    my ($self) = @_;
    return $self->{_right};
}

## ----------------------------------------------------------------------------
## informational

sub isLeaf {
	my ($self) = @_;
	return (!defined $self->{_left} && !defined $self->{_right});
}

sub hasLeft {
    my ($self) = @_;
    return defined $self->{_left};
}

sub hasRight {
    my ($self) = @_;
    return defined $self->{_right};
}

sub isRoot {
	my ($self) = @_;
	return not defined $self->{_parent};
}

## ----------------------------------------------------------------------------
## misc

# NOTE:
# Occasionally one wants to have the 
# depth available for various reasons
# of convience. Sometimes that depth 
# field is not always correct.
# If you create your tree in a top-down
# manner, this is usually not an issue
# since each time you either add a child
# or create a tree you are doing it with 
# a single tree and not a hierarchy.
# If however you are creating your tree
# bottom-up, then you might find that 
# when adding hierarchies of trees, your
# depth fields are all out of whack.
# This is where this method comes into play
# it will recurse down the tree and fix the
# depth fields appropriately.
# This method is called automatically when 
# a subtree is added to a child array
sub fixDepth {
	my ($self) = @_;
	# make sure the tree's depth 
	# is up to date all the way down
	$self->traverse(sub {
			my ($tree) = @_;
            unless ($tree->isRoot()) {
                $tree->{_depth} = $tree->getParent()->getDepth() + 1;            
            }
            else {
                $tree->{_depth} = 0;
            }
		}
	);
}

sub traverse {
	my ($self, $func) = @_;
	(defined($func)) || die "Insufficient Arguments : Cannot traverse without traversal function";
    (ref($func) eq "CODE") || die "Incorrect Object Type : traversal function is not a function";
    $func->($self);
    $self->{_left}->traverse($func) if defined $self->{_left};    
    $self->{_right}->traverse($func) if defined $self->{_right};
}

sub mirror {
    my ($self) = @_;
    # swap left for right
    my $temp = $self->{_left};
    $self->{_left} = $self->{_right};
    $self->{_right} = $temp;
    # and recurse
    $self->{_left}->mirror() if $self->hasLeft();
    $self->{_right}->mirror() if $self->hasRight();
    $self;
}

sub size {
    my ($self) = @_;
    my $size = 1;
    $size += $self->{_left}->size() if $self->hasLeft();
    $size += $self->{_right}->size() if $self->hasRight();    
    return $size;
}

sub height {
    my ($self) = @_;
    my ($left_height, $right_height) = (0, 0);
    $left_height = $self->{_left}->height() if $self->hasLeft();
    $right_height = $self->{_right}->height() if $self->hasRight();    
    return 1 + (($left_height > $right_height) ? $left_height : $right_height);
}

sub accept {
	my ($self, $visitor) = @_;
    # it must be defined, a reference type and ...
	(defined($visitor) && ref($visitor) && 
        # either a Tree::Simple::Visitor object, or ...
        (UNIVERSAL::isa($visitor, "Tree::Binary::Visitor") || 
            # it must be an object which has a 'visit' method avaiable
            (UNIVERSAL::isa($visitor, "UNIVERSAL") && $visitor->can('visit')))) 
		|| die "Insufficient Arguments : You must supply a valid Visitor object";
	$visitor->visit($self);
}

## ----------------------------------------------------------------------------
## cloning 

sub clone {
	my ($self) = @_;
	# create a empty tree
	my $cloned_tree = {
		# do not clone the parent, this
		# would cause serious recursion
		_parent => $self->{_parent},
		# depth is just a number so can 
		# be copied by value
		_depth => $self->{_depth},
		# leave node undefined for now
		_node => undef,
		# and clone the left and right
		};
    $cloned_tree->{_left}  = $self->{_left}->clone() if $self->hasLeft();
    $cloned_tree->{_right} = $self->{_right}->clone() if $self->hasRight();    
	# we need to clone the node	
	my $temp_node = $self->{_node};	
	# if the node is not a reference, 
	# a subroutine reference, a RegEx reference 
	# or a filehandle reference, then just copy
	# it to the new object. 
	if (not ref($temp_node)       || 
		ref($temp_node) eq "CODE" || 
		ref($temp_node) eq "IO"   || 
		ref($temp_node) eq "Regexp") {
		$cloned_tree->{_node} = $temp_node;
	}
	# if the current slot is a scalar reference, then
	# dereference it and copy it into the new object
	elsif (ref($temp_node) eq "SCALAR") {
		my $temp_scalar = ${$temp_node};
		$cloned_tree->{_node} = \$temp_scalar;
	}
	
		## NOTE:
		# a Hash or an Array reference can potentially hold 
		# other references within them, such as a multi-dimensional
		# array or an array of hashes, or a hash of arrays, or any
		# such combination. So if you need this structure to be 
		# copied in depth, it is advised to override this method
		# with a more appropriate one. Otherwise you will receive
		# a shallow copy of these data-structures. Of course, there
		# will be times when a shallow copy is most appropriate. 
		# And at other times it may make more sense to not
		# incur the overhead of the while loop and all the testing that
		# is going on in here.
		
	# if the current slot is an array reference
	# then dereference it and copy it
	elsif (ref($temp_node) eq "ARRAY") {
		$cloned_tree->{_node} = [ @{$temp_node} ];
	}
	# if the current reference is a hash reference
	# then dereference it and copy it
	elsif (ref($temp_node) eq "HASH") {
		$cloned_tree->{_node} = { %{$temp_node} };
	}
	# if the current slot is another object
	# see if the object has a clone method, 
	#  and if so, use it to clone it.
	elsif (UNIVERSAL::isa($temp_node, "UNIVERSAL") && $temp_node->can("clone")){
		$cloned_tree->{_node} = $temp_node->clone();
	}
	else {
		# all other instances where the current slot is
		# a reference but not cloneable are assumed to be
		# un-cloneable object of some sort
		# and the author of the code intends it to not
		# be cloneable as such.
		$cloned_tree->{_node} = $temp_node;
	}	
	bless($cloned_tree, ref($self));
	return $cloned_tree;
}

# this allows cloning of single nodes while retaining connections to a tree
sub cloneShallow {
	my ($self) = @_;
	my $cloned_tree = { %{$self} };
	# just clone the node (if you can)
	$cloned_tree->{_node} = $self->{_node}->clone()
		if (UNIVERSAL::isa($self->{_node}, "UNIVERSAL") && $self->{_node}->can("clone"));
	# if it can not clone, then we can
	# just rely on the copy of node that
	# already there
	bless($cloned_tree, ref($self));
	return $cloned_tree;	
}

## ----------------------------------------------------------------------------
## Desctructor

sub DESTROY {
	my ($self) = @_;
    # we need to call DESTORY on all our children
	# (first checking if they are defined
	# though since we never know how perl's
	# garbage collector will work)
    $self->{_left}->DESTROY() if defined $self->{_left};
    $self->{_right}->DESTROY() if defined $self->{_right};
    $self->{_parent} = undef;
}

1;

__END__

=head1 NAME

Tree::Binary - A Object Oriented Binary Tree for Perl

=head1 SYNOPSIS

  use Tree::Binary;
  
  # a tree representaion of the expression:
  # 	((2 + 2) * (4 + 5))
  my $btree = Tree::Binary->new("*")
                          ->setLeft(
                              Tree::Binary->new("+")
                                          ->setLeft(Tree::Binary->new("2"))
                                          ->setRight(Tree::Binary->new("2"))
                          )
                          ->setRight(
                              Tree::Binary->new("+")
                                          ->setLeft(Tree::Binary->new("4"))
                                          ->setRight(Tree::Binary->new("5"))
                          );  
  # Or shown visually:
  #     +---(*)---+
  #     |         |
  #  +-(+)-+   +-(+)-+
  #  |     |   |     |
  # (2)   (2) (4)   (5)
  
  # get a InOrder visitor
  my $visitor = Tree::Binary::Visitor::InOrderTraversal->new();
  $btree->accept($visitor);    
  
  # print the expression in infix order
  print $visitor->getAccumulation(); # prints "2 + 2 * 4 + 5"
  
  # get a PreOrder visitor
  my $visitor = Tree::Binary::Visitor::PreOrderTraversal->new();
  $btree->accept($visitor);    

  # print the expression in prefix order  
  print $visitor->getAccumulation(); # prints "* + 2 2 + 4 5"
  
  # get a PostOrder visitor
  my $visitor = Tree::Binary::Visitor::PostOrderTraversal->new();
  $btree->accept($visitor);    
  
  # print the expression in postfix order  
  print $visitor->getAccumulation(); # prints "2 2 + 4 5 + *"     
  
  # get a Breadth First visitor
  my $visitor = Tree::Binary::Visitor::BreadthFirstTraversal->new();
  $btree->accept($visitor);    

  # print the expression in breadth first order  
  print $visitor->getAccumulation(); # prints "* + + 2 2 4 5"    
  
  # be sure to clean up all circular references
  $btree->DESTROY();

=head1 DESCRIPTION

This module is a fully object oriented implementation of a binary tree. Binary trees are a specialized type of tree which has only two possible branches, a left branch and a right branch. While it is possible to use an I<n>-ary tree, like L<Tree::Simple>, to fill most of your binary tree needs, a true binary tree object is just easier to mantain and use. 

Binary Tree objects are especially useful (to me anyway) when building parse trees of things like mathematical or boolean expressions. They can also be used in games for such things as descisions trees. Binary trees are a well studied data structure and there is a wealth of information on the web about them. 

This module uses exceptions and a minimal Design By Contract style. All method arguments are required unless specified in the documentation, if a required argument is not defined an exception will usually be thrown. Many arguments are also required to be of a specific type, for instance the C<$tree> argument to both the C<setLeft> and C<setRight> methods, B<must> be a B<Tree::Binary> object or an object derived from B<Tree::Binary>, otherwise an exception is thrown. This may seems harsh to some, but this allows me to have the confidence that my code works as I intend, and for you to enjoy the same level of confidence when using this module. Note however that this module does not use any Exception or Error module, the exceptions are just strings thrown with C<die>.

This object uses a number of methods copied from another module of mine, Tree::Simple. Users of that module will find many similar methods and behaviors. However, it did not make sense for Tree::Binary to be derived from Tree::Simple, as there are a number of methods in Tree::Simple that just wouldn't make sense in Tree::Binary. So, while I normally do not approve of cut-and-paste code reuse, it was what made the most sense in this case.

=head1 METHODS

=over 4

=item B<new ($node)>

The constructor accepts a C<$node> value argument. The C<$node> value can be any scalar value (which includes references and objects).

=back

=head2 Mutators

=over 4

=item B<setNodeValue ($node_value)>

Sets the current Tree::Binary object's node to be C<$node_value>

=item B<setUID ($uid)>

This allows you to set your own unique ID for this specific Tree::Binary object. A default value derived from the object's hex address is provided for you, so use of this method is entirely optional. It is the responsibility of the user to ensure the value's uniqueness, all that is tested by this method is that C<$uid> is a true value (evaluates to true in a boolean context). For even more information about the Tree::Binary UID see the C<getUID> method.

=item B<setLeft ($tree)>

This method sets C<$tree> to be the left subtree of the current Tree::Binary object.

=item B<removeLeft>

This method removed the left subtree of the current Tree::Binary object, making sure to remove all references to the current tree. However, in order to properly clean up and circular references the removed child might have, it is advised to call it's C<DESTROY> method. See the L<CIRCULAR REFERENCES> section for more information.

=item B<setRight ($tree)>

This method sets C<$tree> to be the right subtree of the current Tree::Binary object.

=item B<removeRight>

This method removed the right subtree of the current Tree::Binary object, making sure to remove all references to the current tree. However, in order to properly clean up and circular references the removed child might have, it is advised to call it's C<DESTROY> method. See the L<CIRCULAR REFERENCES> section for more information.

=back

=head2 Accessors

=over 4

=item B<getUID>

This returns the unique ID associated with this particular tree. This can be custom set using the C<setUID> method, or you can just use the default. The default is the hex-address extracted from the stringified Tree::Binary object. This may not be a I<universally> unique identifier, but it should be adequate for at least the current instance of your perl interpreter. If you need a UUID, one can be generated with an outside module (there are many to choose from on CPAN) and the C<setUID> method (see above).

=item B<getParent>

Returns the parent of the current Tree::Binary object.

=item B<getDepth>

Returns the depth of the current Tree::Binary object within the larger hierarchy.

=item B<getNodeValue>

Returns the node value associated with the current Tree::Binary object.

=item B<getLeft>

Returns the left subtree of the current Tree::Binary object.

=item B<getRight>

Returns the right subtree of the current Tree::Binary object.

=back

=head2 Informational 

=over 4

=item B<isLeaf>

A leaf is a tree with no branches, if the current Tree::Binary object does not have either a left or a right subtree, this method will return true (C<1>), otherwise it will return false (C<0>).

=item B<hasLeft>

This method will return true (C<1>) if the current Tree::Binary object has a left subtree, otherwise it will return false (C<0>).

=item B<hasRight>

This method will return true (C<1>) if the current Tree::Binary object has a right subtree, otherwise it will return false (C<0>).

=item B<isRoot>

This method will return true (C<1>) if the current Tree::Binary object is the root (it does not have a parent), otherwise it will return false (C<0>).

=back

=head2 Recursive Methods

=over 4

=item B<traverse ($func)>

This method takes a single argument of a subroutine reference C<$func>. If the argument is not defined and is not in fact a CODE reference then an exception is thrown. The function is then applied recursively to both subtrees of the invocant. Here is an example of a traversal function that will print out the hierarchy as a tabbed in list.

  $tree->traverse(sub {
        my ($_tree) = @_;
        print (("\t" x $_tree->getDepth()), $_tree->getNodeValue(), "\n");
        });
        
=item B<mirror>

This method will swap the left node for the right node and then do this recursively on down the tree. The result is the tree is a mirror image of what it was. So that given this tree:

     +---(-)---+
     |         |
  +-(*)-+   +-(+)-+
  |     |   |     |
 (1)   (2) (4)   (5)     

Calling C<mirror> will result in your tree now looking like this:

     +---(-)---+
     |         |
  +-(+)-+   +-(*)-+
  |     |   |     |
 (5)   (4) (2)   (1) 

It should be noted that this is a destructive action, it will alter your current tree. Although it is easily reversable by simply calling C<mirror> again. However, if you are looking for a mirror copy of the tree, I advise calling C<clone> first.

  my $mirror_copy = $tree->clone()->mirror();

Of course, the cloning operation is a full deep copy, so keep in mind the expense of this operation. Depending upon your needs it may make more sense to call C<mirror> a few times and gather your results with a Visitor object, rather than to C<clone>.

=item B<size>

Returns the total number of nodes in the current tree and all its sub-trees.

=item B<height>

Returns the length of the longest path from the current tree to the furthest leaf node.

=back

=head2 Misc. Methods

=over 4

=item B<accept ($visitor)>

It accepts either a B<Tree::Binary::Visitor::*> object, or an object who has the C<visit> method available (tested with C<$visitor-E<gt>can('visit')>). If these qualifications are not met, and exception will be thrown. We then run the Visitor's C<visit> method giving the current tree as its argument. 

=item B<clone>

The clone method does a full deep-copy clone of the object, calling C<clone> recursively on all its children. This does not call C<clone> on the parent tree however. Doing this would result in a slowly degenerating spiral of recursive death, so it is not recommended and therefore not implemented. What it does do is to copy the parent reference, which is a much more sensible act, and tends to be closer to what we are looking for. This can be a very expensive operation, and should only be undertaken with great care. More often than not, this method will not be appropriate. I recommend using the C<cloneShallow> method instead.

=item B<cloneShallow>

This method is an alternate option to the plain C<clone> method. This method allows the cloning of single B<Tree::Binary> object while retaining connections to the rest of the tree/hierarchy. This will attempt to call C<clone> on the invocant's node if the node is an object (and responds to C<$obj-E<gt>can('clone')>) otherwise it will just copy it.

=item B<DESTROY>

To avoid memory leaks through uncleaned-up circular references, we implement the C<DESTROY> method. This method will attempt to call C<DESTROY> on each of its children (if it as any). This will result in a cascade of calls to C<DESTROY> on down the tree. It also cleans up it's parental relations as well.

Because of perl's reference counting scheme and how that interacts with circular references, if you want an object to be properly reaped you should manually call C<DESTROY>. This is especially nessecary if your object has any children. See the section on L<CIRCULAR REFERENCES> for more information.

=item B<fixDepth>

For the most part, Tree::Binary will manage your tree's depth fields for you. But occasionally your tree's depth may get out of place. If you run this method, it will traverse your tree correcting the depth as it goes.

=back

=head1 CIRCULAR REFERENCES

Perl uses reference counting to manage the destruction of objects, and this can cause problems with circularly referencing object like Tree::Binary. In order to properly manage your circular references, it is nessecary to manually call the C<DESTROY> method on a Tree::Binary instance. Here is some example code:

  # create a root
  my $root = Tree::Binary->new()
  
  { # create a lexical scope
  
      # create a subtree (with a child)
      my $subtree = Tree::Binary->new("1")
                          ->setRight(
                              Tree::Binary->new("1.1")
                          );
                          
      # add the subtree to the root                    
      $root->setLeft($subtree);                    
      
      # ... do something with your trees 
      
      # remove the first child
      $root->removeLeft();
  }

At this point you might expect perl to reap C<$subtree> since it has been removed from the C<$root> and is no longer available outside the lexical scope of the block. However, since C<$subtree> itself has a subtree, its reference count is still (at least) one and perl will not reap it. The solution to this is to call the C<DESTROY> method manually at the end of the lexical block, this will result in the breaking of all relations with the DESTROY-ed object and allow that object to be reaped by perl. Here is a corrected version of the above code.

  # create a root
  my $root = Tree::Binary->new()
  
  { # create a lexical scope
  
      # create a subtree (with a child)
      my $subtree = Tree::Binary->new("1")
                          ->setRight(
                              Tree::Binary->new("1.1")
                          );
                          
      # add the subtree to the root                    
      $root->setLeft($subtree);                    
      
      # ... do something with your trees 
      
      # remove the first child and capture it
      my $removed = $root->removeLeft();
      
      # now force destruction of the removed child
      $removed->DESTROY();
  }

As you can see if the corrected version we used a new variable to capture the removed tree, and then explicitly called C<DESTROY> upon it. Only when a removed subtree has no children (it is a leaf node) can you safely ignore the call to C<DESTROY>. It is even nessecary to call C<DESTROY> on the root node if you want it to be reaped before perl exits, this is especially important in long running environments like mod_perl.

=head1 OTHER TREE MODULES

As crazy as it might seem, there are no pure (non-search) binary tree implementations on CPAN (at least not that I could find). I found several balanaced trees of one kind or another (see the C<OTHER TREE MODULES> section of the Tree::Binary::Search documentation for that list). The closet thing I could find was the Tree module described below.

=over 4

=item B<Tree>

I cannot tell for sure, but this module may include a non-search binary tree in it. Its documentation is beyond non-existant, and I gave up after reading about 3/4 of the source code. It was uploaded in October 1999 and as far as I can tell it has ever been updated (the file modification dates are 05-Jan-1999). There is no actual file called Tree.pm, so CPAN can find no version number. It has no MANIFEST, README of Makefile.PL, so installation is entirely manual. Some of it even appears to have been written by Mark Jason Dominus, as far back as 1997 (possibly the source code from an old TPJ article on B-Trees by him). 

=back

=head1 SEE ALSO

This module is part of a larger group, which are listed below.

=over 4

=item L<Tree::Binary::Search>

=item L<Tree::Binary::VisitorFactory>

=item L<Tree::Binary::Visitor::BreadthFirstTraversal>

=item L<Tree::Binary::Visitor::PreOrderTraversal>

=item L<Tree::Binary::Visitor::PostOrderTraversal>

=item L<Tree::Binary::Visitor::InOrderTraversal>

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, below is the B<Devel::Cover> report on this module test suite.

 -------------------------------------------- ------ ------ ------ ------ ------ ------ ------
 File                                           stmt branch   cond    sub    pod   time  total
 -------------------------------------------- ------ ------ ------ ------ ------ ------ ------
 Tree/Binary.pm                                100.0  100.0   84.4  100.0  100.0   60.8   97.7
 Tree/Binary/Search.pm                          99.0   90.5   81.2  100.0  100.0   22.0   95.1
 Tree/Binary/Search/Node.pm                    100.0  100.0   66.7  100.0  100.0   11.9   98.0
 Tree/Binary/VisitorFactory.pm                 100.0  100.0    n/a  100.0  100.0    0.5  100.0
 Tree/Binary/Visitor/Base.pm                   100.0  100.0   66.7  100.0  100.0    0.6   96.4
 Tree/Binary/Visitor/BreadthFirstTraversal.pm  100.0  100.0  100.0  100.0  100.0    0.0  100.0
 Tree/Binary/Visitor/InOrderTraversal.pm       100.0  100.0  100.0  100.0  100.0    3.4  100.0
 Tree/Binary/Visitor/PostOrderTraversal.pm     100.0  100.0  100.0  100.0  100.0    0.4  100.0
 Tree/Binary/Visitor/PreOrderTraversal.pm      100.0  100.0  100.0  100.0  100.0    0.4  100.0
 -------------------------------------------- ------ ------ ------ ------ ------ ------ ------
 Total                                          99.6   95.1   85.5  100.0  100.0  100.0   97.1
 -------------------------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

