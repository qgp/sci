# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_5,2_6,2_7} )

inherit autotools-utils eutils flag-o-matic fortran-2 multilib python-single-r1 toolchain-funcs

DESCRIPTION="Find total energy, charge density and electronic structure using density functional theory"
HOMEPAGE="http://www.abinit.org/"
SRC_URI="http://ftp.abinit.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="atompaw bigdft cuda cuda-double -debug +etsf_io +fftw fftw-mpi +fftw-threads +fox gsl +hdf5 levmar -libabinit libxc -lotf mpi +netcdf openmp python scalapack scripts -test +threads wannier"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
#"			scalapack? ( !bigdft )"

RDEPEND="virtual/blas
	virtual/lapack
	${PYTHON_DEPS}
	dev-python/numpy
	atompaw? ( >=sci-physics/atompaw-3.0.1.9-r1[libxc?] )
	bigdft? ( ~sci-libs/bigdft-abi-1.0.4[scalapack?] )
	cuda? ( dev-util/nvidia-cuda-sdk )
	etsf_io? ( >=sci-libs/etsf_io-1.0.3-r2 )
	fftw? (
		sci-libs/fftw:3.0
		fftw-threads? (
			openmp? ( sci-libs/fftw:3.0[openmp] )
			!openmp? ( sci-libs/fftw:3.0[threads] )
			)
		fftw-mpi? (
			sci-libs/fftw:3.0[mpi]
			openmp? ( sci-libs/fftw:3.0[openmp] )
			!openmp? ( sci-libs/fftw:3.0[threads] )
			)
		)
	fox? ( >=sci-libs/fox-4.1.2-r2[sax] )
	gsl? ( sci-libs/gsl )
	hdf5? ( sci-libs/hdf5[fortran] )
	levmar? ( sci-libs/levmar )
	libxc? ( >=sci-libs/libxc-2.0[fortran]
			<sci-libs/libxc-2.2 )
	netcdf? (
		sci-libs/netcdf[hdf5?]
		|| (
			sci-libs/netcdf[fortran]
			sci-libs/netcdf-fortran
			)
		)
	mpi? ( virtual/mpi )
	scalapack? ( virtual/scalapack )
	scripts? ( dev-python/PyQt4 )
	wannier? ( >=sci-libs/wannier90-1.2-r1 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	dev-perl/Text-Markdown"

S=${WORKDIR}/${P%[a-z]}

DOCS=( AUTHORS ChangeLog COPYING INSTALL KNOWN_PROBLEMS NEWS PACKAGING
	README README.ChangeLog README.GPU README.xlf RELNOTES THANKS )

FORTRAN_STANDARD=90

pkg_setup() {
	# Doesn't compile with gcc-4.0, only >=4.1
	if [[ $(tc-getFC) == *gfortran ]]; then
		if [[ $(gcc-major-version) -eq 4 ]] \
			&& [[ $(gcc-minor-version) -lt 1  ]]; then
				die "Requires gcc-4.1 or newer"
		fi
	fi

	# fortran-2.eclass does not handle mpi wrappers
	if use mpi; then
		export FC="mpif90"
		export F77="mpif77"
		export CC="mpicc"
		export CXX="mpic++"
	else
		tc-export FC F77 CC CXX
	fi

	# Preprocesor macross can make some lines really long
	append-fflags -ffree-line-length-none

	# This should be correct:
	#   It is gcc-centric because toolchain-funcs.eclass is gcc-centric.
	#   Should a bug be filed against toolchain-funcs.eclass?
	# if use openmp; then
	#         tc-has-openmp || \
	#                 die "Please select an openmp capable compiler like gcc[openmp]"
	# fi
	#
	# This is completely wrong:
	#   If other compilers than Gnu Compiler Collection can be used by portage,
	#   their support of OpenMP should be properly tested. This code limits the test
	#   to gcc, and blindly supposes that other compilers do support OpenMP.
	# if use openmp && [[ $(tc-getCC)$ == *gcc* ]] &&	! tc-has-openmp; then
	# 	die "Please select an openmp capable compiler like gcc[openmp]"
	# fi
	#
	# Luckily Abinit is a fortran package.
	#   fortran-2.eclass has its own test for OpenMP support,
	#   more general than toolchain-funcs.eclass
	#   The test itself proceeds inside fortran-2_pkg_setup
	if use openmp; then FORTRAN_NEED_OPENMP=1; fi

	fortran-2_pkg_setup

	if use openmp; then
		# based on _fortran-has-openmp() of fortran-2.eclass
		local code=ebuild-openmp-flags
		local ret
		local openmp

		pushd "${T}"
		cat <<- EOF > "${code}.c"
		# include <omp.h>
		main () {
			int nthreads;
			nthreads=omp_get_num_threads();
		}
		EOF

		for openmp in -fopenmp -xopenmp -openmp -mp -omp -qsmp=omp; do
			${CC} ${openmp} "${code}.c" -o "${code}.o" &>> "${T}"/_c_compile_test.log
			ret=$?
			(( ${ret} )) || break
		done

		rm -f "${code}.*"
		popd

		if (( ${ret} )); then
			die "Please switch to an openmp compatible C compiler"
		else
			export CC="${CC} ${openmp}"
			export CXX="${CXX} ${openmp}"
		fi

		pushd "${T}"
		cat <<- EOF > "${code}.f"
		1     call omp_get_num_threads
		2     end
		EOF

		for openmp in -fopenmp -xopenmp -openmp -mp -omp -qsmp=omp; do
			${FC} ${openmp} "${code}.f" -o "${code}.o" &>> "${T}"/_f_compile_test.log
			ret=$?
			(( ${ret} )) || break
		done

		rm -f "${code}.*"
		popd

		if (( ${ret} )); then
			die "Please switch to an openmp compatible fortran compiler."
		else
			export FC="${FC} ${openmp}"
			export F77="${F77} ${openmp}"
		fi
	fi

	# Sort out some USE options
	if use fftw-threads && ! use fftw; then
		ewarn "fftw-threads set but fftw not used, ignored."
	fi
	if use fftw-mpi; then
		if ! use fftw; then
			ewarn "fftw-mpi set but fftw not used, ignored."
		elif ! use mpi; then
			ewarn "fftw-mpi set but mpi not used, ignored."
		elif ! use fftw-threads; then
			ewarn "fftw-mpi set but fftw-threads not. Will use a threaded fftw nevertheless, required with MPI."
		fi
	fi
	if use cuda-double && ! use cuda; then
		ewarn "cuda-double set but cuda not used, ignored"
	fi

	python-single-r1_pkg_setup

}

src_prepare() {
	epatch \
		"${FILESDIR}"/6.2.2-change-default-directories.patch \
		"${FILESDIR}"/6.12.1-autoconf.patch \
		"${FILESDIR}"/6.12.1-xmalloc.patch \
		"${FILESDIR}"/7.6.3-libabinit_options.patch \
		"${FILESDIR}"/7.4.2-levmar_diag_scaling.patch \
		"${FILESDIR}"/7.4.2-syntax.patch \
		"${FILESDIR}"/7.4.2-cuda_link_stdc++.patch \
		"${FILESDIR}"/7.6.4-cuda_header.patch \
		"${FILESDIR}"/7.6.4-libxc_versions.patch
	eautoreconf
	sed -e"s/\(grep '\^-\)\(\[LloW\]\)'/\1\\\(\2\\\|pthread\\\)'/g" -i configure
	python_fix_shebang "${S}"
}

src_configure() {
	local modules="$(FoX-config --sax --fcflags)"
	local FoX_libs="$(FoX-config --sax --libs)"

	local trio_flavor=""
	use etsf_io && trio_flavor="${trio_flavor}+etsf_io"
	use fox && trio_flavor="${trio_flavor}+fox"
	use netcdf && trio_flavor="${trio_flavor}+netcdf"
	test "no${trio_flavor}" = "no" && trio_flavor="none"

	local netcdff_libs="-lnetcdff"
	use hdf5 && netcdff_libs="${netcdff_libs} -lhdf5_fortran"

#	local linalg_flavor="atlas"
	local linalg_flavor="custom"
	local mylapack="lapack"
	use scalapack && mylapack="scalapack" && linalg_flavor="${linalg_flavor}+scalapack"

	local dft_flavor=""
	use atompaw && dft_flavor="${dft_flavor}+atompaw"
	use bigdft && dft_flavor="${dft_flavor}+bigdft"
	use libxc && dft_flavor="${dft_flavor}+libxc"
	use wannier && dft_flavor="${dft_flavor}+wannier90"
	test "no${dft_flavor}" = "no" && dft_flavor="none"

	local fft_flavor="fftw3"
	local fft_libs=""
	# The fftw threads support is protected by black magick.
	# Anybody removes it, dies.
	# New USE flag "fftw-threads" was added to control usage
	# of the threaded fftw variant. Since fftw-3.3 has expanded
	# the paralel options by MPI and OpenMP support, analogical
	# USE flags should be added to select them in future;
	# unusable with previous FFTW versions, they are postponed
	# for now.
	if use mpi && use fftw-mpi; then
		fft_flavor="fftw3-mpi"
		fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3_mpi)"
		fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3f_mpi)"
		if use openmp; then
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3_omp)"
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3f_omp)"
		else
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3_threads)"
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3f_threads)"
		fi
	elif use fftw-threads; then
		fft_flavor="fftw3-threads"
		if use openmp; then
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3_omp)"
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3f_omp)"
		else
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3_threads)"
			fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3f_threads)"
		fi
	else
		fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3)"
		fft_libs+="$($(tc-getPKG_CONFIG) --libs fftw3f)"
	fi

	local gpu_flavor="none"
	if use cuda; then
		gpu_flavor="cuda-single"
		if use cuda-double; then
			gpu_flavor="cuda-double"
		fi
	fi

	local myeconfargs=(
		--enable-clib
		--enable-exports
		--enable-pkg-check
		$(use_enable debug debug enhanced)
		$(use_enable mpi)
		$(use_enable mpi mpi-io)
		$(use_enable openmp)
		$(use_enable lotf)
		$(use_enable cuda gpu)
		"$(use cuda && echo "--with-gpu-flavor=${gpu_flavor}")"
		"$(use cuda && echo "--with-gpu-prefix=/opt/cuda/")"
		"$(use gsl && echo "--with-math-flavor=gsl")"
		"$(use gsl && echo "--with-math-incs=$($(tc-getPKG_CONFIG) --cflags gsl)")"
		"$(use gsl && echo "--with-math-libs=$($(tc-getPKG_CONFIG) --libs gsl)")"
		"$(use levmar && echo "--with-algo-flavor=levmar")"
		"$(use levmar && echo "--with-algo-libs=-llevmar")"
		--with-linalg-flavor="${linalg_flavor}"
		--with-linalg-libs="$($(tc-getPKG_CONFIG) --libs "${mylapack}")"
		--with-trio-flavor="${trio_flavor}"
		"$(use netcdf && echo "--with-netcdf-incs=-I/usr/include")"
		"$(use netcdf && echo "--with-netcdf-libs=$($(tc-getPKG_CONFIG) --libs netcdf) ${netcdff_libs}")"
		"$(use fox && echo "--with-fox-incs=${modules}")"
		"$(use fox && echo "--with-fox-libs=${FoX_libs}")"
		"$(use etsf_io && echo "--with-etsf-io-incs=${modules}")"
		"$(use etsf_io && echo "--with-etsf-io-libs=-letsf_io -letsf_io_utils -letsf_io_low_level")"
		--with-dft-flavor="${dft_flavor}"
		"$(use atompaw && echo "--with-atompaw-incs=${modules}")"
		"$(use atompaw && echo "--with-atompaw-libs=-latompaw")"
		"$(use bigdft && echo "--with-bigdft-incs=${modules}")"
		"$(use bigdft && echo "--with-bigdft-libs=$($(tc-getPKG_CONFIG) --libs bigdft)")"
		"$(use libxc && echo "--with-libxc-incs=${modules}")"
		"$(use libxc && echo "--with-libxc-libs=$($(tc-getPKG_CONFIG) --libs libxc)")"
		"$(use wannier && echo "--with-wannier90-bins=/usr/bin")"
		"$(use wannier && echo "--with-wannier90-incs=${modules}")"
		"$(use wannier && echo "--with-wannier90-libs=-lwannier $($(tc-getPKG_CONFIG) --libs blas lapack)")"
		"$(use fftw && echo "--with-fft-flavor=${fft_flavor}")"
		"$(use fftw && echo "--with-fft-incs=-I/usr/include")"
		"$(use fftw && echo "--with-fft-libs=${fft_libs}")"
		--with-timer-flavor="abinit"
		LD="$(tc-getLD)"
		FCFLAGS="${FCFLAGS:- ${FFLAGS:- -O2}} ${modules} -I/usr/include"
		)

	MARKDOWN=Markdown.pl autotools-utils_src_configure
}

src_compile() {
	autotools-utils_src_compile

	# Apparently libabinit.a is not built by default
	# Used by BigDFT. Should probably be built separately,
	# as a package of its own: BigDFT used by Abinit.
	# Does libabinit.a depend on BigDFT, if used?
	# Can Abinit use external libabinit.a?
	use libabinit && autotools-utils_src_compile libabinit.a

	sed -i -e's/libatlas/lapack/' "${AUTOTOOLS_BUILD_DIR}"/config.pc
}

src_test() {
	einfo "The complete tests take quite a while, easily several hours or even days."
	# autotools-utils_src_test expanded and modified
	_check_build_dir
	pushd "${BUILD_DIR}" > /dev/null || die

	einfo "Running the internal tests."
	emake tests_in || die 'The internal tests failed.'

	einfo "Running the thorough tests. Be patient, please."
	"${S}"/tests/runtests.py || ewarn "The package has not passed the thorough tests."

	popd > /dev/null || die
}

src_install() {
	#autotools-utils_src_install() expanded
	_check_build_dir
	pushd "${AUTOTOOLS_BUILD_DIR}" > /dev/null
	emake DESTDIR="${D}" install || die "make install failed"

	use libabinit && dolib libabinit.a

	if use test; then
		for dc in results.tar.gz results.txt suite_report.html; do
			test -e Test_suite/"${dc}" && dodoc Test_suite/"${dc}" || ewarn "Copying tests results ${dc} failed"
		done
	fi

	popd > /dev/null

	# XXX: support installing them from builddir as well!!!
	if [[ ${DOCS} ]]; then
		dodoc "${DOCS[@]}" || die "dodoc failed"
	else
		local f
		# same list as in PMS
		for f in README* ChangeLog AUTHORS NEWS TODO CHANGES \
				THANKS BUGS FAQ CREDITS CHANGELOG; do
			if [[ -s ${f} ]]; then
				dodoc "${f}" || die "(default) dodoc ${f} failed"
			fi
		done
	fi
	if [[ ${HTML_DOCS} ]]; then
		dohtml -r "${HTML_DOCS[@]}" || die "dohtml failed"
	fi

	if use scripts; then
		insinto /usr/share/"${P}"
		doins -r scripts
	fi

	# Remove libtool files and unnecessary static libs
	prune_libtool_files
}
