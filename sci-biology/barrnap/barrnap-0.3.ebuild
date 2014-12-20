# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit perl-module

DESCRIPTION="Predict Bacterial and Archaeal rRNA genes and output in GFF3 format"
HOMEPAGE="http://www.vicbioinformatics.com/software.barrnap.shtml"
SRC_URI="http://www.vicbioinformatics.com/"${P}".tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

# contains bundled binaries of hmmer-3.1 (dev version)

DEPEND=""
RDEPEND="${DEPEND}
	>=dev-lang/perl-5.6
	sci-biology/nesoni"

src_install(){
	# the below recreates the whole layout
	insinto /usr/share/"${PN}"
	doins barrnap
	chmod a+rx "${D}"/usr/share/"${PN}"/barrnap
	insinto /usr/share/"${PN}"/binaries
	doins binaries/nhmmer.linux
	chmod a+rx "${D}"/usr/share/"${PN}"/binaries/nhmmer.linux
	insinto /usr/share/"${PN}"/db
	doins db/*
	insinto /usr/share/examples
	doins examples/*

	echo PATH=/usr/share/"${PN}":$PATH > "${S}"/99barrnap
	doenvd "${S}"/99barrnap
}
