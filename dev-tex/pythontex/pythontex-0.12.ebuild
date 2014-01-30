# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_2,3_3} )

inherit latex-package python-single-r1

DESCRIPTION="Fast Access to Python from within LaTeX"
HOMEPAGE="https://github.com/gpoore/pythontex"
SRC_URI="https://github.com/gpoore/pythontex/raw/master/package_downloads/${PN}_${PV}.zip https://github.com/gpoore/pythontex/raw/master/package_downloads/old_versions/${PN}_${PV}.zip"

SLOT="0"
LICENSE="LPPL-1.3 BSD"
KEYWORDS="~amd64"
IUSE="highlighting"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}
	app-text/texlive"
RDEPEND="${DEPEND}
	dev-texlive/texlive-xetex
	>=dev-python/matplotlib-1.2.0[${PYTHON_USEDEP}]
	highlighting? ( dev-python/pygments[${PYTHON_USEDEP}] )"

TEXMF=/usr/share/texmf-site

S="${WORKDIR}"/${PN}
src_prepare() {
	rm pythontex.sty || die "Could not remove pythontex.sty!"
}

src_compile() {
	ebegin "Compiling ${PN}"
	latex ${PN}.ins extra > "${T}"/build-latex.log || die "Building style from ${PN}.ins failed"
	eend
	sed -i -e '1i#!/usr/bin/env python' depythontex2.py || die "adding shebang failed!"
	sed -i -e '1i#!/usr/bin/env python' depythontex3.py || die "adding shebang failed!"
}

src_install() {
	python_optimize .
	if python_is_python3; then
		python_newscript pythontex3.py pythontex.py
		python_newscript depythontex3.py depythontex.py
	else
		python_newscript pythontex2.py pythontex.py
		python_doscript pythontex_2to3.py
		python_newscript depythontex2.py depythontex.py
	fi

	python_export PYTHON_SCRIPTDIR

	python_moduleinto ${PYTHON_SCRIPTDIR}
	python_domodule "${S}"/pythontex_engines.py "${S}"/pythontex_utils.py

	insinto /usr/share/texmf-site/tex/latex/pythontex/
	doins "${S}"/pythontex.sty

	insinto /usr/share/texmf-site/source/latex/pythontex/
	doins "${S}"/pythontex.dtx "${S}"/pythontex.ins

	latex-package_src_install

	dodoc README
	mktexlsr
}
