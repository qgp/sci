# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Adaptor and MID removal / trimming tool, also for Illumina-oriented paired-end reads"
HOMEPAGE="http://sourceforge.net/projects/skewer"
SRC_URI="http://sourceforge.net/projects/skewer/files/Binaries/skewer-0.1.104-linux-x86_64
		http://sourceforge.net/projects/skewer/files/Scripts/srna-scripts-0.1.2.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	dev-lang/perl"

src_install() {
	cp "${DISTDIR}"/skewer-* skewer || die
	dobin *.pl || die
	dobin skewer || die "Failed to install clview binary"
}
