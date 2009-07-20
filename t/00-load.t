#!perl

BEGIN {
    use File::Find;
    use Test::More;

    my $dir = './lib';
    my @modules;

    unshift @INC, $dir;

    find(sub {
        $_ = $File::Find::name;
        if(s, ^ $dir /? (.*) \.pm $ ,$1,x) {
            s,/,::,g;
            push @modules, $_;
        }
    }, $dir);

    plan tests => int(@modules);

    for my $mod (@modules) {
        use_ok($mod);
    }
}
