# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

WANT_AUTOCONF="2.5"
WANT_AUTOMAKE="1.10"

inherit git-r3 autotools linux-mod toolchain-funcs udev flag-o-matic

DESCRIPTION="Lustre is a parallel distributed file system"
HOMEPAGE="http://wiki.whamcloud.com/"
SRC_URI=""
EGIT_REPO_URI="git://git.whamcloud.com/fs/lustre-release.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+client +utils server liblustre readline tests tcpd +urandom"

RDEPEND="
	virtual/awk
	readline? ( sys-libs/readline )
	tcpd? ( sys-apps/tcp-wrappers )
	server? (
		>=sys-kernel/spl-0.6.1
		>=sys-fs/zfs-kmod-0.6.1
		sys-fs/zfs
	)
	"
DEPEND="${RDEPEND}
	virtual/linux-sources"

PATCHES=(
	"${FILESDIR}/0001-LU-2982-build-make-AC-check-for-linux-arch-sandbox-f.patch"
	"${FILESDIR}/0002-LU-3373-ldiskfs-ldiskfs-patches-for-3.11.1-fc19.patch"
	"${FILESDIR}/0003-LU-3974-llite-dentry-d_compare-changes-in-3.11.patch"
	"${FILESDIR}/0004-LU-3974-llite-use-new-struct-dir_context.patch"
	"${FILESDIR}/0005-LU-3974-llite-invalidatepage-api-changed.patch"
	"${FILESDIR}/0006-LU-3319-procfs-move-llite-proc-handling-over-to-seq_.patch"
	"${FILESDIR}/0007-LU-3319-procfs-move-lmv-proc-handling-over-to-seq_fi.patch"
	"${FILESDIR}/0008-LU-3319-procfs-move-ldlm-proc-handling-over-to-seq_f.patch"
	"${FILESDIR}/0009-LU-3319-procfs-move-ost-proc-handling-over-to-seq_fi.patch"
	"${FILESDIR}/0010-LU-3319-procfs-update-shared-server-side-core-proc-h.patch"
	"${FILESDIR}/0011-LU-3319-procfs-update-zfs-proc-handling-to-seq_files.patch"
	"${FILESDIR}/0012-LU-3319-procfs-move-mgs-proc-handling-to-seq_files.patch"
	"${FILESDIR}/0013-LU-3319-procfs-move-ofd-proc-handling-to-seq_files.patch"
	"${FILESDIR}/0014-LU-3319-procfs-move-lod-proc-handling-to-seq_files.patch"
	"${FILESDIR}/0015-LU-3319-procfs-move-osp-proc-handling-to-seq_files.patch"
	"${FILESDIR}/0016-LU-3319-procfs-move-mdt-mds-proc-handling-to-seq_fil.patch"
	"${FILESDIR}/0017-LU-3319-procfs-move-mdd-proc-handling-to-seq_files.patch"
	"${FILESDIR}/0018-LU-3319-procfs-update-ldiskfs-proc-handling-to-seq_f.patch"
)

pkg_setup() {
	filter-mfpmath sse
	filter-mfpmath i386
	filter-flags -msse* -mavx* -mmmx -m3dnow
	linux-mod_pkg_setup
	ARCH="$(tc-arch-kernel)"
	ABI="${KERNEL_ABI}"
}

src_prepare() {
	epatch ${PATCHES[@]}
	# replace upstream autogen.sh by our src_prepare()
	local DIRS="libcfs lnet lustre snmp"
	local ACLOCAL_FLAGS
	for dir in $DIRS ; do
		ACLOCAL_FLAGS="$ACLOCAL_FLAGS -I $dir/autoconf"
	done
	eaclocal -I config $ACLOCAL_FLAGS
	eautoheader
	eautomake
	eautoconf
	# now walk in configure dirs
	einfo "Reconfiguring source in libsysio"
	cd libsysio
	eaclocal
	eautomake
	eautoconf
	cd ..
}

src_configure() {
	local myconf
	if use server; then
		SPL_PATH=$(basename $(echo "${EROOT}usr/src/spl-"*)) \
			myconf="${myconf} --with-spl=${EROOT}usr/src/${SPL_PATH} \
							--with-spl-obj=${EROOT}usr/src/${SPL_PATH}/${KV_FULL}"
		ZFS_PATH=$(basename $(echo "${EROOT}usr/src/zfs-"*)) \
			myconf="${myconf} --with-zfs=${EROOT}usr/src/${ZFS_PATH} \
							--with-zfs-obj=${EROOT}usr/src/${ZFS_PATH}/${KV_FULL}"
	fi
	econf \
		${myconf} \
		--without-ldiskfs \
		--disable-ldiskfs-build \
		--with-linux="${KERNEL_DIR}" \
		--with-linux-release="${KV_FULL}" \
		$(use_enable client) \
		$(use_enable utils) \
		$(use_enable server) \
		$(use_enable liblustre) \
		$(use_enable readline) \
		$(use_enable tcpd libwrap) \
		$(use_enable urandom) \
		$(use_enable tests)
}

src_compile() {
	default
}

src_install() {
	default
}
