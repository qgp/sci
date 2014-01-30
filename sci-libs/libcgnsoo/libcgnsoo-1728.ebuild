# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PV="3.0"
MY_PN=${PN}-${MY_PV}

DESCRIPTION="CGNSOO library, provides an object-oriented interface to the CGNS Mid-level library"
HOMEPAGE="http://openfoam-extend.sourceforge.net"
SRC_URI="http://ppa.launchpad.net/cae-team/ppa/ubuntu/pool/main/libc/${MY_PN}/${MY_PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sci-libs/cgnslib"

RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_PN}-${PV}

src_configure() {
	chmod +x configure
	econf --with-CGNSLIBHOME="/usr"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
