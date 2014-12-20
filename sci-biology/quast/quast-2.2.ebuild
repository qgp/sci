# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit python-r1

DESCRIPTION="Compare quality of multiple genome assemblies to each other"
HOMEPAGE="http://bioinf.spbau.ru/QUAST"
SRC_URI="http://sourceforge.net/projects/quast/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	dev-python/matplotlib[${PYTHON_USEDEP}]
	sci-biology/mummer
	sci-biology/glimmerhmm"
#	sci-biology/GAGE
#	sci-biology/GeneMarkS
#	sci-biology/MetaGeneMark"

# the above packages need to be created first

RDEPEND="${DEPEND}"

src_install(){
	python_foreach_impl python_newscript quast.py quast
	python_foreach_impl python_newscript metaquast.py metaquast

	dodoc manual.html CHANGES

	# TODO: install lib/ subdirectory contents into some PATH and PYTHON_PATH
}
