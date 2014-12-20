# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1 git-r3

DESCRIPTION="Python module to support computational pipelines"
HOMEPAGE="http://www.ruffus.org.uk"
# SRC_URI="http://code.google.com/p/ruffus/downloads/detail?name=ruffus-2.4beta3.tar.gz"
EGIT_REPO_URI="http://code.google.com/p/ruffus"
# git@github.com:bunbun/ruffus.git

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
		media-gfx/graphviz"
RDEPEND="${DEPEND}"
