# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Convert from ace to gap4 (of staden v1.x), not needed to convert ace for gap5 of staden v2"
HOMEPAGE="http://genome.imb-jena.de/software/roche454ace2caf"
SRC_URI="http://genome.imb-jena.de/software/roche454ace2caf/download/src/roche454ace2gap-2010-12-08.tgz"

LICENSE="FLI-Jena"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
		sci-biology/align_to_scf
		sci-biology/sff_dump
		sci-biology/caftools
		sci-biology/staden
		dev-lang/perl
		app-shells/ksh"

S="${WORKDIR}"/roche2gap

src_install(){
	dobin bin/*.pl bin/roche454ace2gap
	dosym bin/roche454ace2gap roche2gap # claims to require ksh, have not tested bash
}
