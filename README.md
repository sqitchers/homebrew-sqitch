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
PostgreSQL server) and SQLite (requires the Homebrew SQLite build).

    brew install sqitch_pg
    brew install sqitch_sqlite

Interested in hacking on Sqitch? Of course you should
[fork it](https://github.com/theory/sqitch), and then install the dependencies
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


