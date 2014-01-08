# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils toolchain-funcs

DESCRIPTION="Converts CCP4 mtz-files containing anomalous data to Scalepack format"
HOMEPAGE="http://shelx.uni-ac.gwdg.de/~tg/mtz2x/mtz2sca"
SRC_URI="http://shelx.uni-ac.gwdg.de/~tg/mtz2x/${PN}/binaries/${PV}/${PN}_v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sci-libs/ccp4-libs"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/

src_prepare() {
	epatch "${FILESDIR}"/${PV}-gentoo.patch
}

src_compile() {
	emake \
		CXX=$(tc-getCXX) \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}"
}

src_install() {
	dobin ${PN}
}
