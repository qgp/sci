# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit fortran-2 multilib toolchain-funcs

DESCRIPTION="a compiler cache for fortran"
HOMEPAGE="http://people.irisa.fr/Edouard.Canot/f90cache/"
SRC_URI="http://people.irisa.fr/Edouard.Canot/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-util/ccache"

src_prepare() {
	sed -i -e '/OBJS/s/CFLAGS/LDFLAGS/' -e '/strip/d' Makefile.in || die
}

src_install() {
	default
	dohtml web/*

	#we depend on ccache, put links in there so that portage fined it
	#TODO improve this
	dosym "/usr/bin/f90cache" "${ROOT}/usr/$(get_libdir)/ccache/bin/gfortran"
}

pkg_postinst() {
	elog "Please add F90CACHE_DIR=\"${ROOT%/}/var/tmp/f90cache\""
	elog "to your make.conf otherwise f90cache files end up in"
	elog "home of the user executing portage"
}
