#!/usr/bin/perl
use 5.006000;
use ExtUtils::MakeMaker;
#See lib/ExtUtils/MakeMaker.pm for details of how to influence
#the contents of the Makefile that is written.
%_ = (
  NAME         => 'Net::DirectConnect::TigerHash',
  VERSION_FROM => 'lib/Net/DirectConnect/TigerHash.pm',    # finds $VERSION
       #PREREQ_PM    => {},                                      # e.g., Module::Name => 1.1
  (
    $] >= 5.005
    ?    ## Add these new keywords supported since 5.005
      (
      ABSTRACT_FROM => 'lib/Net/DirectConnect/TigerHash.pm',    # retrieve abstract from module
      AUTHOR        => 'Charlie & <proler@gmail.com>'
      )
    : ()
  ),
  #LIBS   => [''],                                               # e.g., '-lm'
  DEFINE => '-I./dcpp/ -I../dcpp/',                             # e.g., '-DHAVE_SOMETHING'
                                                                #Insert -I. if you add *.h files later:
  INC    => '-I.',                                              # e.g., '-I/usr/include/other'
                                                                #Un-comment this if you add C files to link with later:
                                                                #OBJECT            => '$(O_FILES)', # link all the C files too
  'CC'   => 'g++',
  'LD'   => '$(CC)',
);
$_{dist} = {
  PREOP    => "pod2text $_{VERSION_FROM} | tee README >\$(DISTVNAME)/README; chmod -R u=rwX,go=rX . ;",
  COMPRESS => 'gzip -9v',
  SUFFIX   => '.gz',
};
WriteMakefile(%_);

sub MY::postamble {
  my @dcppfiles = qw(DCPlusPlus.h Encoder.cpp Encoder.h HashValue.h MerkleTree.h TigerHash.cpp TigerHash.h stdinc.h typedefs.h);
  my $dcppfiles = join ' ', map { './eiskaltdcpp/dcpp/' . $_ } @dcppfiles;
  #config.h DCPlusPlus.cpp  stdinc.h
  qq{
#docs: README

#README: $_{VERSION_FROM}
#pod2text $_{VERSION_FROM} > README

fullclean: distclean veryclean
	rm -rf \$(DISTNAME)-*.tar.gz *.bak *.old *.core MANIFEST README eiskaltdcpp
    
release: test fullclean manifest metafile dist
} . (
    $^O eq 'MSWin32'
    ? ()
    : qq{
download:
	[ -d eiskaltdcpp ] || git clone git://github.com/negativ/eiskaltdcpp.git
	cp $dcppfiles ./dcpp

patchmake:
	mkdir -p patch
} . (
      join '',
      map {
        qq{	diff -u ./eiskaltdcpp/dcpp/$_ dcpp/$_ > patch/$_ || true
}
        } @dcppfiles
      )
      . qq{

patchapply:
} . (
      join '',
      map {
        qq{	patch -N dcpp/$_ < patch/$_ || true
}
        } @dcppfiles
      )
      . qq{
update: download patchapply

}
  );
}
