# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="A pairwise DNA sequence aligner (also chromosome to chromosome), a BLASTZ replacement"
HOMEPAGE="http://www.bx.psu.edu/~rsharris/lastz/"
SRC_URI="http://www.bx.psu.edu/~rsharris/lastz/newer/${P}.tar.gz"

SLOT="0"
LICENSE="all-rights-reserved"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}"/lastz-distrib-"${PV}"

RESTRICT="mirror"

src_prepare() {
	append-lfs-flags
	epatch "${FILESDIR}"/${P}-build.patch

	tc-export CC
}

src_install(){
	dobin src/lastz src/lastz_D
	dodoc README.lastz.html
	dohtml lav_format.html
}
