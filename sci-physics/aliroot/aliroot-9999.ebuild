# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic cmake-utils subversion
ESVN_PROJECT="AliRoot"
ESVN_RESTRICT="export"

if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="http://svn.cern.ch/guest/AliRoot/trunk"
else
	ESVN_REPO_URI="http://svn.cern.ch/guest/AliRoot/tags/${PV}"
fi;

DESCRIPTION="ALICE computing framework"
HOMEPAGE="http://aliweb.cern.ch/Offline"
SRC_URI=""

LICENSE="ALICE"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="alien geant3 geant4 fluka fastjet"

DEPEND="alien? ( sci-physics/root[alien] )"
RDEPEND="${DEPEND}"

src_unpack ()
{
	local wc_path="$(subversion__get_wc_path "${ESVN_REPO_URI}")"
	cd "${wc_path}" || die "${ESVN}: can't chdir to ${wc_path}"
	mkdir -p "${S}"

	subversion_src_unpack

	# copy working copy to build dir (we need .svn)
	rsync -rlpgo . "${S}" || die "${ESVN}: can't export to ${S}."
}

src_configure ()
{
	export ALICE_ROOT="${WORKDIR}/${P}"
	export ALICE="/opt/alice"
	export ALICE_INSTALL="${ALICE}/aliroot/${PV}"

	# ROOTSYS is not available for a ROOT system installation
	# setting dummy value for ROOTSYS to make cmake happy
	# export ROOTSYS="/tmp"

	# aliroot does not compile with --as-needed
	filter-ldflags -Wl,--as-needed

	local mycmakeargs=(-DCMAKE_INSTALL_PREFIX="${ALICE_INSTALL}")

	cmake-utils_src_configure
}

src_prepare ()
{
	epatch "${FILESDIR}/rootsys.patch"
	default
}

src_install ()
{
	cmake-utils_src_install

	echo "LDPATH=${ALICE_INSTALL}/lib/tgt_$(root-config --arch)" > 99aliroot
	echo "PATH=${ALICE_INSTALL}/bin/tgt_$(root-config --arch)" >> 99aliroot

	doenvd 99aliroot
}
