# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils cmake-utils subversion
ESVN_PROJECT="AliRoot"
ESVN_RESTRICT="export"

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

src_unpack ()
{
	einfo "test: ${ESVN_REPO_URI}"

	local wc_path="$(subversion__get_wc_path "${ESVN_REPO_URI}")"
	cd "${wc_path}" || die "${ESVN}: can't chdir to ${wc_path}"
	mkdir -p "${S}"
	
	einfo "test: ${ESVN_REPO_URI}"
	subversion_src_unpack
	# copy working copy to build dir (we need .svn)
	rsync -rlpgo . "${S}"
	#|| die "${ESVN}: can't export to ${S}."
}

src_configure ()
{
	export ALICE_ROOT="${WORKDIR}/${P}"
	export ROOTSYS="/tmp"

	cmake-utils_src_configure
}
