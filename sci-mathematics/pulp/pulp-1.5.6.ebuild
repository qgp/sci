# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3,3_4} pypy )

inherit distutils-r1

MY_PN="PuLP"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Create MPS/LP files, call solvers, and present results"
HOMEPAGE="http://pulp-or.googlecode.com/"
SRC_URI="mirror://pypi/P/PuLP/${MY_P}.zip"

LICENSE="BSD-2"
KEYWORDS="~amd64"
SLOT="0"
IUSE="examples"

DEPEND="dev-python/setuptools"
RDEPEND="
	dev-python/setuptools
	dev-python/pyparsing
	sci-libs/coinor-cbc
	>=sci-mathematics/glpk-4.35"

S="${WORKDIR}/${MY_P}"

python_prepare_all() {
	rm -rf ./src/pulp/solverdir/cbc* || die
	distutils-r1_python_prepare_all
}

pyhton_install_all() {
	distutils-r1_python_install_all
	if use examples; then
		insinto /usr/share/doc/"${PF}"/
		doins -r examples
	fi
}
