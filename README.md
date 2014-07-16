Sqitch Homebrew Tap
===================

This Homebrew tap provides formulas for [Sqitch](http://sqitch.org/), a
database schema development and change management system. If you'd like to try
Sqitch and use [Homebrew](http://mxcl.github.com/homebrew/), this will be the
simplest way to get it installed so you can get to work.

First, use this command to set up the Sqitch Homebrew tap:

    brew tap theory/sqitch

Now you can install the core Sqitch application:

    brew install sqitch

It won't do you much good without support for your database, though.
Currently, there are builds for PostgreSQL (requires the Homebrew core
PostgreSQL server), SQLite (requires the Homebrew SQLite build), MySQL
(requires the Homebrew MySQL build), Firebird (requires the
[Firebird database](http://www.firebirdsql.org)), and Oracle (requires
[Oracle Instant Client](http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html)
([installation instructions](http://www.talkapex.com/2013/03/oracle-instant-client-on-mac-os-x.html#comment-form)).

    brew install sqitch_pg
    brew install sqitch_sqlite
    brew install sqitch_mysql
    brew install sqitch_firebird
    ORACLE_HOME=/oracle/instantclient_11_2 brew install sqitch_oracle

Interested in hacking on Sqitch? Of course you should
[fork it](https://github.com/theory/sqitch/fork), and then install the dependencies
for maintaining Sqitch:

    brew install sqitch_maint_depends

Just want the latest from Git without forking? Use the `--HEAD` option to
install Sqitch (and the maintenance dependencies):

    brew install sqitch --HEAD

Acknowledgments
---------------

Many thanks to @mistydemeo for the guidance, suggestions, and feedback. It
would have taken a lot longer to create this tap without her help.

Author
------

[David E. Wheeler](http://justatheory.com/)


