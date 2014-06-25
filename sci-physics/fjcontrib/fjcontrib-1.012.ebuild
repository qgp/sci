# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="FastJet contrib"
HOMEPAGE="http://www.fastjet.fr"
SRC_URI="http://fastjet.hepforge.org/contrib/downloads/fjcontrib-1.012.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
	./configure
}

src_prepare() {
	sed -i -e 's#$(PREFIX)#$(DESTDIR)/$(PREFIX)#' $(find -name Makefile)
}

src_install() {
	make DESTDIR="${D}" install
#	einstall
}
