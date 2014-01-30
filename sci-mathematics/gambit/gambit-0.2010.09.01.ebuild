# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

WX_GTK_VER="2.8"

inherit wxwidgets

DESCRIPTION="Gambit: Software Tools for Game Theory"
HOMEPAGE="http://www.gambit-project.org/doc/index.html"
SRC_URI="mirror://sourceforge/gambit/${P}.tar.gz"
	#http://econweb.tamu.edu/gambit/doc/${PN}-manual-${PV}.pdf
	#http://econweb.tamu.edu/gambit/doc/${PN}-manual-${PV}.tar.gz

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="X"

DEPEND="
	X? (
		x11-libs/wxGTK:2.8[X]
		x11-libs/gtk+:2 )"
RDEPEND="${DEPEND}"

src_configure() {
	local myconf
	if use amd64; then
		myconf='--disable-enumpoly'
	fi
	econf "${myconf}" \
		$(use_enable X gui)
}
