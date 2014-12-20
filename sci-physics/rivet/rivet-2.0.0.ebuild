# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Rivet"
HOMEPAGE="http://rivet.hepforge.org"
SRC_URI="http://www.hepforge.org/archive/rivet/Rivet-2.0.0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="sci-physics/yoda
	dev-cpp/yaml-cpp
	sci-physics/fastjet
	sci-physics/hepmc
	media-gfx/imagemagick
	dev-texlive/texlive-pstricks"
RDEPEND="${DEPEND}"

S="${WORKDIR}/Rivet-${PV}"

src_compile() {
	# avoid sandbox violation by TeX font creation
	export VARTEXFONTS="${T}/fonts"

	default_src_compile
}
