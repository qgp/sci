# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod

DESCRIPTION="Berkeley Lab Checkpoint/Restart for Linux"
HOMEPAGE="https://ftg.lbl.gov/projects/CheckpointRestart"
SRC_URI="https://ftg.lbl.gov/assets/projects/CheckpointRestart/downloads/"${PN}"-"${PV}".tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND=""

MAKEOPTS="${MAKEOPTS} -j1"

# up to kernel 2.6.38

pkg_setup() {
	local msg
	linux-info_pkg_setup

	# kernel version check
	if kernel_is gt 2 6 38
	then
		eerror "${PN} is being developed and tested up to linux-2.6.38."
		eerror "Make sure you have a proper kernel version and point"
		eerror "  /usr/src/linux symlink or env variable KERNEL_DIR to it!"
		die "Wrong kernel version ${KV}"
	fi

	linux-mod_pkg_setup
	MODULE_NAMES="blcr(blcr::${S}/cr_module/kbuild)
		blcr_imports(blcr::${S}/blcr_imports/kbuild)"
	BUILD_TARGETS="clean all"
	ECONF_PARAMS="--with-kernel=${KV_DIR}"
}

src_install() {
	dodoc README NEWS
	cd "${S}"/util || die
	emake DESTDIR="${D}" install || die "binaries install failed"
	cd "${S}"/libcr || die
	emake DESTDIR="${D}" install || die "libcr install failed"
	cd "${S}"/man || die
	emake DESTDIR="${D}" install || die "man install failed"
	cd "${S}"/include || die
	emake DESTDIR="${D}" install || die "headers install failed"
	linux-mod_src_install
}

pkg_postinst() {
	linux-mod_pkg_postinst
	einfo "Be sure to add blcr to your modules.autoload.d to"
	einfo "ensure that the modules get loaded on your next boot"
}
