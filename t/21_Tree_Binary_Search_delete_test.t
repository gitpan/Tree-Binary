#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

BEGIN { 
    use_ok('Tree::Binary::Search');
    use_ok('Tree::Binary::Visitor::InOrderTraversal');
}

# NOTE:
# this test will check that the nodes are deleted from the
# tree, and the tree behaves as expected. It test the three
# cases as described in :
# http://www.msu.edu/~pfaffben/avl/libavl.html/Deleting-from-a-BST.html
# which should be reasonably sufficient.

my $btree = Tree::Binary::Search->new();
isa_ok($btree, 'Tree::Binary::Search');

# sub show_tree {
#     my $visitor = Tree::Binary::Visitor::InOrderTraversal->new();
#     $visitor->setNodeFilter(sub {
#         my ($t) = @_;
#         diag(("  |" x $t->getDepth()) . "--" . $t->getNodeKey());
#     });
#     $btree->getTree()->accept($visitor);
# }

sub check_tree {
    my (@expected_results) = @_;
    my $visitor = Tree::Binary::Visitor::InOrderTraversal->new();
    $btree->getTree()->accept($visitor);
    is_deeply(
            [ $visitor->getResults() ],
            [ @expected_results ],
            '... our delete worked');
}

$btree->useNumericComparison();

$btree->insert(5 => 5);
$btree->insert(2 => 2);
$btree->insert(1 => 1);
$btree->insert(3 => 3);
$btree->insert(4 => 4);
$btree->insert(9 => 9);
$btree->insert(8 => 8);
$btree->insert(6 => 6);
$btree->insert(7 => 7);

check_tree(1, 2, 3, 4, 5, 6, 7, 8, 9);
#show_tree;

ok($btree->delete(8), '... the node was successfully deleted');
check_tree(1, 2, 3, 4, 5, 6, 7, 9);
#show_tree;

ok($btree->delete(2), '... the node was successfully deleted');
check_tree(1, 3, 4, 5, 6, 7, 9);
#show_tree;

ok($btree->delete(5), '... the node was successfully deleted');
check_tree(1, 3, 4, 6, 7, 9);
#show_tree;