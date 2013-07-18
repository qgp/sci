# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-chemistry/ccp4-apps/ccp4-apps-6.1.3-r12.ebuild,v 1.2 2013/02/27 16:53:35 jlec Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit cmake-utils fortran-2 python-single-r1

MY_P="${PN/-apps}-${PV}"

DESCRIPTION="Protein X-ray crystallography toolkit - Application bundle"
HOMEPAGE="http://www.ccp4.ac.uk/"
SRC_URI="ftp://ftp.ccp4.ac.uk/ccp4/${PV}/${MY_P}-core-src.tar.gz"

LICENSE="ccp4"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"
IUSE="+deprecated examples +unsupported X"

X11DEPS="
	x11-libs/libX11
	x11-libs/libXaw
	x11-libs/libXt
	x11-libs/libxdl_view"

TKDEPS="
	dev-lang/tcl
	dev-lang/tk
	>=dev-tcltk/blt-2.4
	dev-tcltk/iwidgets
	dev-tcltk/itcl
	dev-tcltk/itk
	>=dev-tcltk/tdom-0.8
	dev-tcltk/tktreectrl"

SCILIBS="
	~sci-libs/ccp4-libs-${PV}
	sci-libs/ccif
	sci-libs/clipper
	sci-libs/fftw:2.1
	sci-libs/libccp4
	sci-libs/mmdb
	sci-libs/ssm
	virtual/blas
	virtual/lapack"

SCIAPPS="
	sci-chemistry/pdb-extract
	sci-chemistry/pymol
	sci-chemistry/rasmol
	>=sci-chemistry/oasis-4.0-r1"

RDEPEND="
	${TKDEPS}
	${SCILIBS}
	app-shells/tcsh
	dev-python/pyxml
	dev-libs/libxml2:2
	dev-libs/libjwc_c
	dev-libs/libjwc_f
	dev-libs/boehm-gc
	!app-office/sc
	!<sci-chemistry/ccp4-6.1.3
	X? ( ${X11DEPS} )"
DEPEND="${RDEPEND}
	X? (
		x11-misc/imake
		x11-proto/inputproto
		x11-proto/xextproto
	)"
PDEPEND="${SCIAPPS}"

RESTRICT="mirror"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${P}-unbundle.patch
	"${FILESDIR}"/${P}-share.patch
)

HTML_DOCS=( "${S}"/html/. )

pkg_setup() {
	fortran-2_pkg_setup
	python-single-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_build deprecated)
		$(cmake-utils_use_build unsupported)
	)
	cmake-utils_src_configure
}

src_install() {
	find lib/data/monomers -delete || die
	cmake-utils_src_install
	python_fix_shebang "${ED}"/usr/bin/*py
	dodir /usr/libexec/ccp4
	mv "${ED}"/usr/{bin,libexec/ccp4/} || die

	if use examples; then
		for i in data rnase toxd; do
			docinto examples/${i}
			dodoc "${S}"/examples/${i}/*
		done

		docinto examples/tutorial
		dohtml -r "${S}"/examples/tutorial/html examples/tutorial/tut.css
		for i in data results; do
			docinto examples/tutorial/${i}
			dodoc "${S}"/examples/tutorial/${i}/*
		done

		for i in non-runnable runnable; do
			docinto examples/unix/${i}
			dodoc "${S}"/examples/unix/${i}/*
		done
	fi
	# Needed for ccp4i docs to work
	dosym ../../share/doc/${PF}/examples /usr/$(get_libdir)/ccp4/examples || die
	dosym ../../share/doc/${PF}/html /usr/$(get_libdir)/ccp4/html || die

}
