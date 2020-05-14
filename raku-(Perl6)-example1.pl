use v6;


# equivalent of typeof is .^name or .WHAT
# say 42.^name;       # OUTPUT: «Int␤»
# say $scalar.WHAT;   # (Int)

# .elems only works on Lists, Arrays etc, not Match.


sub MAIN()
{
    my $currentDirectory = '.';
    my @directoryTree    = $currentDirectory.IO;

    while @directoryTree
    {
        for @directoryTree.pop.dir -> $path
        {
            if ( $path.IO ~~ :f && $path.Str ~~ m:g/GTK3test.html/ )
            {
                ReadThisFile( $path.Str )
            }
            @directoryTree.push: $path if $path.d;
        }
    }
}

sub ReadThisFile(Str $someFile)
{   
    my $file = $someFile.IO.open: :rw;

    my regex targetLineSearchPattern { ^ \s* \< h3 \> \< a \s .* href \= . \/ content \/ }

    for $file.lines -> $line
    {
        if $line.match( &targetLineSearchPattern )
        {
            CraftAFileName( $line );
        }
    }

}

sub CraftAFileName(Str $sourceLine)
{

    my regex fileNameKeyWord { \w };

    say $sourceLine.contains( &fileNameKeyWord );

}













            #say $path.Str if $path.IO ~~ :f;
            #test( $path.Str ) if $path.IO ~~ :f;

#say ('abc' ~~ m:g/./).elems;

#my $text = prompt('Text> ');
#$text ~~ m:g/(\w+)/;
#say $/.elems;