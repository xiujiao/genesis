#!perl
use strict;
use warnings;

use lib 'lib';
use lib 't';
use helper;
use Test::Deep;

use_ok 'Genesis::Root';

my $tmp = workdir();
sub again {
	system("rm -rf $tmp/.genesis/kits; mkdir -p $tmp/.genesis/kits");
	system("touch $tmp/.genesis/kits/$_") for (qw/
		foo-1.0.0.tar.gz
		foo-1.0.1.tgz
		foo-0.9.6.tar.gz
		foo-0.9.5.tar.gz
		bar-3.4.5.tar.gz

		not-a-kit-file
		unversioned.tar.gz
		unversioned.tgz
	/);
}

my $root = Genesis::Root->new($tmp);

again();
ok(!$root->has_dev_kit, "roots without dev/ should not report having a dev kit");
cmp_deeply($root->compiled_kits, {
		foo => {
			'0.9.5' => "$tmp/.genesis/kits/foo-0.9.5.tar.gz",
			'0.9.6' => "$tmp/.genesis/kits/foo-0.9.6.tar.gz",
			'1.0.0' => "$tmp/.genesis/kits/foo-1.0.0.tar.gz",
			'1.0.1' => "$tmp/.genesis/kits/foo-1.0.1.tgz",
		},
		bar => {
			'3.4.5' => "$tmp/.genesis/kits/bar-3.4.5.tar.gz",
		},
	}, "roots should list out all of their compiled kits");

again();
ok( defined $root->find_kit(foo => '1.0.0'), "test root dir should have foo-1.0.0 kit");
ok(!defined $root->find_kit(foo => '9.8.7'), "test root dir should not have foo-9.8.7 kit");
ok(!defined $root->find_kit(quxx => undef), "test root dir should not have any quux kit");
ok( defined $root->find_kit(foo => '1.0.1'), "roots should recognize .tgz kits");
ok( defined $root->find_kit(foo => 'latest'), "root should find latest kit versions");
is($root->find_kit(foo => 'latest')->{version}, '1.0.1', "the latest foo kit should be 1.0.1");
is($root->find_kit(foo => undef)->{version}, '1.0.1', "an undef version should count as 'latest'");

done_testing;
