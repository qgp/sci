# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Symbolic and algebraic computations system"
HOMEPAGE="http://www.open-axiom.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="X"

RDEPEND="X? ( x11-libs/libXpm )"
DEPEND="${RDEPEND}
	app-text/noweb
	>=dev-lisp/sbcl-1.0.22"

DOCS="MAINTAINERS TODO STYLES"

src_configure() {
	# There is an option to compile with other lisps. However:
	# - gcl is getting obsolete and unmaintained and is hard masked
	# - could not make it work with ecls
	econf \
		--with-lisp=sbcl \
		$(use_with X x)
}

src_compile() {
	# unfortunately could not track down the broken parallel build
	# -j5 ok but -j30 sbcl stalled
	emake -j1
}
