#!/bin/bash

set -e

mkdir -p /opt/t87/software/perlbrew /opt/t87/conf

export PERLBREW_ROOT=/opt/t87/software/perlbrew

export ALL_PROXY=http://wwwcache.sanger.ac.uk:3128/
export HTTP_PROXY="${ALL_PROXY}"
export http_proxy="${ALL_PROXY}"
export HTTPS_PROXY="${ALL_PROXY}"
export https_proxy="${ALL_PROXY}"
export FTP_PROXY="${ALL_PROXY}"
export ftp_proxy="${ALL_PROXY}"

curl -kL http://xrl.us/perlbrewinstall | bash

source ${PERLBREW_ROOT}/etc/bashrc

perlbrew install 5.14.2

perlbrew switch 5.14.2

perlbrew install-cpanm

cpanm ack
cpanm Const::Fast
cpanm Log::Log4perl
cpanm Term::ReadPassword
cpanm Test::Most
cpanm DBIx::Class
cpanm DBIx::Class::Schema::Loader
cpanm DBD::Pg
cpanm Catalyst::Runtime
cpanm Catalyst::Manual
cpanm Catalyst::Devel
cpanm MooseX::App::Cmd
cpanm MooseX::Types::Path::Class
cpanm MooseX::Log::Log4perl
cpanm MooseX::MarkAsMethods
cpanm MooseX::NonMoose
cpanm Dist::Zilla



