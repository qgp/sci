# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils cmake-utils subversion
ESVN_PROJECT="AliRoot"

if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="http://svn.cern.ch/guest/AliRoot/trunk"
else
	ESVN_REPO_URI="http://svn.cern.ch/guest/AliRoot/tags/${PV}"
fi;

DESCRIPTION="ALICE computing framework"
HOMEPAGE="http://aliweb.cern.ch/Offline"

LICENSE="ALICE"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_configure ()
{
	export ALICE_ROOT="${WORKDIR}/${P}"
	export ROOTSYS="/tmp"

	cmake-utils_src_configure
}
