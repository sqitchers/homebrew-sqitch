require 'formula'

class Sqitch < Formula
  homepage 'http://sqitch.org/'
  url 'http://cpan.metacpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-0.952.tar.gz'
  sha1 '478aeffa99499aed363f83c611360f6e56d1e1d5'
  head 'https://github.com/theory/sqitch.git'

  depends_on 'Capture::Tiny' => :perl # >= 0.12
  depends_on 'Config' => :perl
  depends_on 'Config::GitLike' => :perl # >= 1.09
  depends_on 'constant' => :perl
  depends_on 'DateTime' => :perl
  depends_on 'DBI' => :perl
  depends_on 'Digest::SHA1' => :perl
  depends_on 'Encode' => :perl
  depends_on 'File::Basename' => :perl
  depends_on 'File::Copy' => :perl
  depends_on 'File::HomeDir' => :perl
  depends_on 'File::Path' => :perl
  depends_on 'File::Spec' => :perl
  depends_on 'File::Temp' => :perl
  depends_on 'Getopt::Long' => :perl
  depends_on 'Hash::Merge' => :perl
  depends_on 'IO::Pager' => :perl
  depends_on 'IPC::System::Simple' => :perl # >= 1.17
  depends_on 'List::Util' => :perl
  depends_on 'List::MoreUtils' => :perl
  depends_on 'Locale::TextDomain' => :perl # >= 1.20
  depends_on 'Module::Build' => :perl # >= 0.35
  depends_on 'Moose' => :perl # >= 2.0300
  depends_on 'Moose::Meta::Attribute::Native' => :perl # >= 2.0300
  depends_on 'Moose::Meta::TypeConstraint::Parameterizable' => :perl # >= 2.0300
  depends_on 'Moose::Util::TypeConstraints' => :perl # >= 2.0300
  depends_on 'MooseX::Types::Path::Class' => :perl # >= 0.05
  depends_on 'namespace::autoclean' => :perl # >= 0.11
  depends_on 'parent' => :perl
  depends_on 'overload' => :perl
  depends_on 'Path::Class' => :perl
  depends_on 'Pod::Find' => :perl
  depends_on 'Pod::Usage' => :perl
  depends_on 'POSIX' => :perl
  depends_on 'Role::HasMessage' => :perl # >= 0.005
  depends_on 'Role::Identifiable::HasIdent' => :perl # >= 0.005
  depends_on 'Role::Identifiable::HasTags' => :perl # >= 0.005
  depends_on 'StackTrace::Auto' => :perl
  depends_on 'strict' => :perl
  depends_on 'String::Formatter' => :perl
  depends_on 'Sub::Exporter' => :perl
  depends_on 'Sub::Exporter::Util' => :perl
  depends_on 'Sys::Hostname' => :perl
  depends_on 'Template::Tiny' => :perl # >= 0.11
  depends_on 'Term::ANSIColor' => :perl # >= 2.02
  depends_on 'Test::Deep' => :perl
  depends_on 'Test::Dir' => :perl
  depends_on 'Test::Exception' => :perl
  depends_on 'Test::File' => :perl
  depends_on 'Test::File::Contents' => :perl # >= 0.05
  depends_on 'Test::MockModule' => :perl # >= 0.05
  depends_on 'Test::More' => :perl # >= 0.94
  depends_on 'Test::NoWarnings' => :perl # >= 0.083
  depends_on 'Throwable' => :perl
  depends_on 'Try::Tiny' => :perl
  depends_on 'URI' => :perl
  depends_on 'User::pwent' => :perl
  depends_on 'utf8' => :perl
  depends_on 'warnings' => :perl

  def install
    system "perl Build.PL"
    system "./Build"
    system "./Build install"
  end
end
