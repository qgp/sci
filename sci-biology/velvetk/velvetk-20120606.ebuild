# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit perl-module

DESCRIPTION="Estimate the best k-mer size to use for your Velvet de novo assembly"
HOMEPAGE="http://www.vicbioinformatics.com/software.velvetk.shtml"
SRC_URI="http://www.vicbioinformatics.com/velvetk.pl"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare(){
	cp -p "${DISTDIR}"/velvetk.pl . || die
}

src_install(){
	dobin velvetk.pl
}
