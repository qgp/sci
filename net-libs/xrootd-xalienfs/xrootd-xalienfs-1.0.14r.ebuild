# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="ALICE grid suite"
HOMEPAGE="http://alien2.cern.ch"
SRC_URI="http://alitorrent.cern.ch/src/xalienfs/xrootd-xalienfs-1.0.14r.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="net-libs/xrootd"
RDEPEND="${DEPEND}"

src_prepare ()
{
	./bootstrap.sh
}

src_configure ()
{
	econf --with-xrootd-location="${EPREFIX}/usr"
}
