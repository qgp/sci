# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs

MY_PN="${PN#lib}"

DESCRIPTION="libunzip.so"
HOMEPAGE="http://www.info-zip.org/"
SRC_URI="mirror://gentoo/${MY_PN}${PV/.}.tar.gz"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-no-exec-stack.patch
	epatch "${FILESDIR}"/${P}-CVE-2008-0888.patch #213761
	epatch "${FILESDIR}"/${P}-Makefile.patch
	sed -i \
		-e 's:-O3:$(CFLAGS) $(CPPFLAGS):' \
		-e 's:-O :$(CFLAGS) $(CPPFLAGS) :' \
		-e "s:CC=gcc :CC=$(tc-getCC) :" \
		-e "s:CC = cc:CC=$(tc-getCC) :" \
		-e "s:LD=gcc :LD=$(tc-getCC) :" \
		-e "s:AS=gcc :AS=$(tc-getCC) :" \
		-e "s:RANLIB =:RANLIB = $(tc-getRANLIB) :" \
		-e 's:LF2 = -s:LF2 = :' \
		-e 's:LF = :LF = $(LDFLAGS) :' \
		-e 's:SL = :SL = $(LDFLAGS) :' \
		-e 's:FL = :FL = $(LDFLAGS) :' \
		unix/Makefile \
		|| die "sed unix/Makefile failed"
}

src_compile() {
	append-lfs-flags #104315
	emake -f unix/Makefile linux_shlib || die "emake failed"
}

src_install() {
	dolib.so ${PN}.so.0.4 || die
	dolib.so ${PN}.so.0 || die
	dolib.so ${PN}.so || die
	dolib.a ${PN}.a || die
	insinto /usr/include
	doins unzip.h || die
}
