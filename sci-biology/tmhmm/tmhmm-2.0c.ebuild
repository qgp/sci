# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Prediction of transmembrane helices in proteins"
HOMEPAGE="http://www.cbs.dtu.dk/services/TMHMM/"
SRC_URI="${P}.Linux.tar.gz"

LICENSE="tmhmm"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND=""

RESTRICT="fetch"

S="TMHMM${PV}"

pkg_nofetch() {
	einfo "Please visit ${HOMEPAGE} and obtain the file"
	einfo "\"${SRC_URI}\", then place it in ${DISTDIR}"
}

src_prepare() {
	sed -i '1 i #!/usr/bin/env perl' "${S}"/bin/tmhmm* || die
	sed -i '1 a $opt_basedir = "/opt/tmhmm";' "${S}"/bin/tmhmm || die
}

src_install() {
	exeinto /opt/${PN}/bin
	doexe bin/* || die
	insinto /opt/${PN}/lib
	doins lib/* || die
	dosym /opt/${PN}/bin/tmhmm /usr/bin/tmhmm
	dodoc README TMHMM2.0.html
}
