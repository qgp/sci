# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit cmake-utils git-r3 python-single-r1

DESCRIPTION="Parallelization engine for optimization problems"
HOMEPAGE="http://pagmo.sourceforge.net/"
SRC_URI=""
EGIT_REPO_URI="git://pagmo.git.sourceforge.net/gitroot/pagmo/pagmo"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="gsl kepler mpi nlopt python test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	dev-libs/boost[mpi?]
	python? (
		${PYTHON_DEPS}
		dev-libs/boost[${PYTHON_USEDEP}]
		)
	nlopt? ( sci-libs/nlopt )
	gsl? ( sci-libs/gsl )"
DEPEND="${RDEPEND}"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	mycmakeargs=(
		-DENABLE_SNOPT=OFF
		-DBUILD_MAIN=OFF
		$(cmake-utils_use_build python PYGMO)
		$(cmake-utils_use_enable gsl GSL)
		$(cmake-utils_use_enable kepler KEPLERIAN_TOOLBOX)
		$(cmake-utils_use_enable mpi MPI)
		$(cmake-utils_use_enable nlopt NLOPT)
		$(cmake-utils_use_enable test TESTS)
	)
	cmake-utils_src_configure
}
