# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

JAVA_PKG_OPT_USE="gui"
VIRTUALX_REQUIRED="manual"

inherit eutils autotools bash-completion-r1 check-reqs fdo-mime flag-o-matic \
	fortran-2 java-pkg-opt-2 toolchain-funcs virtualx

MY_PV="${PV/_beta1/-beta-1}"
MY_P="$PN"-"$MY_PV"

# Things that don't work:
# - tests
# - can't build without docs (-doc) 

DESCRIPTION="Scientific software package for numerical computations"
HOMEPAGE="http://www.scilab.org/"
SRC_URI="http://www.scilab.org/download/${MY_PV}/${MY_P}-src.tar.gz"

LICENSE="CeCILL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion debug +doc fftw +gui +matio nls openmp
	static-libs test tk +umfpack +xcos"
REQUIRED_USE="xcos? ( gui ) doc? ( gui )"

# ALL_LINGUAS variable defined in configure.ac
LINGUAS="fr_FR zh_CN zh_TW ca_ES es_ES pt_BR"
for l in ${LINGUAS}; do
	IUSE="${IUSE} linguas_${l}"
done
LINGUASLONG="de_DE ja_JP it_IT uk_UA pl_PL ru_RU"
for l in ${LINGUASLONG}; do
	IUSE="${IUSE} linguas_${l%_*}"
done

CDEPEND="dev-libs/libpcre
	dev-libs/libxml2:2
	sci-libs/hdf5
	>=sci-libs/arpack-3
	sys-devel/gettext
	sys-libs/ncurses
	sys-libs/readline
	virtual/lapack
	fftw? ( sci-libs/fftw:3.0 )
	gui? (
		dev-java/avalon-framework:4.2
		dev-java/batik:1.7
		dev-java/commons-io:1
		>=dev-java/flexdock-1.2.4:0
		dev-java/fop:0
		dev-java/gluegen:2
		dev-java/javahelp:0
		dev-java/jeuclid-core:0
		dev-java/jgoodies-looks:2.0
		dev-java/jgraphx:2.1
		dev-java/jlatexmath:1
		dev-java/jogl:2
		>=dev-java/jrosetta-1.0.4:0
		dev-java/skinlf:0
		dev-java/xmlgraphics-commons:1.5
		virtual/opengl
		doc? ( dev-java/saxon:9 )
		xcos? ( dev-java/commons-logging:0 ) )
	matio? ( >=sci-libs/matio-1.5 )
	tk? ( dev-lang/tk )
	umfpack? ( sci-libs/umfpack )"

RDEPEND="${CDEPEND}
	gui? ( >=virtual/jre-1.5 )"

DEPEND="${CDEPEND}
	virtual/pkgconfig
	debug? ( dev-util/lcov )
	gui? (
		>=virtual/jdk-1.5
		doc? ( app-text/docbook-xsl-stylesheets
			   dev-java/xml-commons-external:1.4
			   dev-java/jlatexmath-fop:1 )
		xcos? ( dev-lang/ocaml ) )
	test? (
		dev-java/junit:4
		gui? ( ${VIRTUALX_DEPEND} ) )"

DOCS=( "ACKNOWLEDGEMENTS" "README_Unix" "Readme_Visual.txt" )

S="${WORKDIR}"/"${MY_P}"

pkg_pretend() {
	use doc && CHECKREQS_MEMORY="512M" check-reqs_pkg_pretend
}

pkg_setup() {
	if use openmp; then
		if [[ $(tc-getCC) == *gcc* ]] && ! tc-has-openmp; then
			ewarn "You are using a gcc without OpenMP capabilities"
			die "Need an OpenMP capable compiler"
		fi
		FORTRAN_NEED_OPENMP=1
	fi
	FORTRAN_STANDARD="77 90"
	fortran-2_pkg_setup
	java-pkg-opt-2_pkg_setup

	ALL_LINGUAS="en_US"
	for l in ${LINGUAS}; do
		use linguas_${l} && ALL_LINGUAS="${ALL_LINGUAS} ${l}"
	done
	for l in ${LINGUASLONG}; do
		use linguas_${l%_*} && ALL_LINGUAS="${ALL_LINGUAS} ${l}"
	done
	export ALL_LINGUAS ALL_LINGUAS_DOC=$ALL_LINGUAS
}

src_prepare() {
	epatch \
		"${FILESDIR}/${P}-followlinks.patch" \
		"${FILESDIR}/${P}-gluegen.patch" \
		"${FILESDIR}/${P}-fix-random-runtime-failure.patch" \
		"${FILESDIR}/${P}-disable-static-systemlib.patch" \
		"${FILESDIR}/${P}-always-use-dynamic-stack.patch" \
		"${FILESDIR}/${P}-accessviolation.patch"

	append-ldflags $(no-as-needed)

	# increases java heap to 512M when building docs (sync with cheqreqs above)
	use doc && epatch "${FILESDIR}/${P}-java-heap.patch"

	# use the LINGUAS variable that we set
	sed -i -e "/^ALL_LINGUAS=/d" -e "/^ALL_LINGUAS_DOC=/d" -i configure.ac ||die

	# make sure the DOCBOOK_ROOT variable is set
	sed -i -e "s/xsl-stylesheets-\*/xsl-stylesheets/g" bin/scilab* || die

	#add specific gentoo java directories
	if use gui; then
		sed -i -e "s|/usr/lib/jogl2|/usr/lib/jogl-2|" \
			-e "s|/usr/lib64/jogl2|/usr/lib64/jogl-2|" configure.ac || die
		sed -i -e "s|/usr/lib/gluegen2|/usr/lib/gluegen-2|" \
			-e "s|/usr/lib64/gluegen2|/usr/lib64/gluegen-2|" \
			-e "s|AC_CHECK_LIB(\[gluegen2-rt|AC_CHECK_LIB([gluegen-rt|" \
			configure.ac || die

		sed -i -e "s/jogl2/jogl-2/" -e "s/gluegen2/gluegen-2/" \
			etc/librarypath.xml || die
	fi

	mkdir jar || die
	pushd jar
	java-pkg_jar-from jgraphx-2.1,jlatexmath-1,flexdock,skinlf
	java-pkg_jar-from jgoodies-looks-2.0,jrosetta
	java-pkg_jar-from avalon-framework-4.2,jeuclid-core
	java-pkg_jar-from xmlgraphics-commons-1.5,commons-io-1
	java-pkg_jar-from jogl-2 jogl-all.jar jogl2.jar
	java-pkg_jar-from gluegen-2 gluegen-rt.jar gluegen2-rt.jar
	java-pkg_jar-from batik-1.7 batik-all.jar
	java-pkg_jar-from fop fop.jar
	java-pkg_jar-from javahelp jhall.jar
	if use xcos; then
		java-pkg_jar-from commons-logging
	fi
	if use doc; then
		java-pkg_jar-from saxon-9 saxon.jar saxon9he.jar
		java-pkg_jar-from jlatexmath-fop-1
		java-pkg_jar-from xml-commons-external-1.4 xml-apis-ext.jar
	fi
	if use test; then
		java-pkg_jar-from junit-4 junit.jar junit4.jar
	fi
	popd

	java-pkg-opt-2_src_prepare
	eautoconf
}

src_configure() {
	if use gui; then
		export JAVA_HOME="$(java-config -O)"
	else
		unset JAVAC
	fi

	export BLAS_LIBS="$($(tc-getPKG_CONFIG) --libs blas)"
	export LAPACK_LIBS="$($(tc-getPKG_CONFIG) --libs lapack)"
	export F77_LDFLAGS="${LDFLAGS}"
	# gentoo bug #302621
	has_version sci-libs/hdf5[mpi] && \
		export CXX=mpicxx CC=mpicc

	econf \
		--enable-relocatable \
		--disable-rpath \
		--with-docbook="${EPREFIX}/usr/share/sgml/docbook/xsl-stylesheets" \
		--disable-static-system-lib \
		$(use_enable debug) \
		$(use_enable debug code-coverage) \
		$(use_enable debug debug-C) \
		$(use_enable debug debug-CXX) \
		$(use_enable debug debug-fortran) \
		$(use_enable debug debug-java) \
		$(use_enable debug debug-linker) \
		$(use_enable doc build-help) \
		$(use_enable nls) \
		$(use_enable nls build-localization) \
		$(use_enable static-libs static) \
		$(use_enable test compilation-tests) \
		$(use_with fftw) \
		$(use_with gui) \
		$(use_with gui javasci) \
		$(use_with matio) \
		$(use_with openmp) \
		$(use_with tk) \
		$(use_with umfpack) \
		$(use_with xcos) \
		$(use_with xcos modelica)
}

src_compile() {
	emake
	use doc && emake doc
}

src_test() {
	if use gui; then
		Xemake check
	else
		emake check
	fi
}

src_install() {
	default
	prune_libtool_files --all
	rm -rf "${D}"/usr/share/scilab/modules/*/tests ||die
	use bash-completion && newbashcomp "${FILESDIR}"/"${PN}".bash_completion "${PN}"
	echo "SEARCH_DIRS_MASK=${EPREFIX}/usr/$(get_libdir)/scilab" \
		> 50-"${PN}"
	insinto /etc/revdep-rebuild && doins "50-${PN}"
}

pkg_postinst() {
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_mime_database_update
}