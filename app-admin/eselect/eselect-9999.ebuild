# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="git://github.com/gentoo-science/eselect.git"
EGIT_BRANCH="alternatives"

inherit autotools git-r3 bash-completion-r1

DESCRIPTION="Gentoo's multi-purpose configuration and management tool"
HOMEPAGE="http://wiki.gentoo.org/wiki/Project:Eselect"

LICENSE="GPL-2+ || ( GPL-2+ CC-BY-SA-2.5 )"
SLOT="0"
IUSE="doc emacs vim-syntax"

RDEPEND="sys-apps/sed
	|| (
		sys-apps/coreutils
		sys-freebsd/freebsd-bin
		app-misc/realpath
	)"
DEPEND="${RDEPEND}
	doc? ( dev-python/docutils )"
RDEPEND="!app-admin/eselect-news
	${RDEPEND}
	sys-apps/file
	sys-libs/ncurses"

PDEPEND="emacs? ( app-emacs/eselect-mode )
	vim-syntax? ( app-vim/eselect-syntax )"

src_prepare() {
	eautoreconf
}

src_compile() {
	emake
	use doc && emake html
}

src_install() {
	emake DESTDIR="${D}" install
	newbashcomp misc/${PN}.bashcomp ${PN}
	dodoc AUTHORS ChangeLog NEWS README TODO doc/*.txt
	use doc && dohtml *.html doc/*

	# needed by news module
	keepdir /var/lib/gentoo/news
	if use prefix; then
		sed -i \
			"s:ALTERNATIVESDIR_ROOTLESS=\"${EPREFIX}:ALTERNATIVESDIR_ROOTLESS=\":" \
			"${ED}"/usr/share/eselect/libs/alternatives-common.bash || die
	else
		fowners root:portage /var/lib/gentoo/news
		fperms g+w /var/lib/gentoo/news
	fi
}

pkg_postinst() {
	# fowners in src_install doesn't work for the portage group:
	# merging changes the group back to root
	if ! use prefix; then
		chgrp portage "${EROOT}/var/lib/gentoo/news" \
			&& chmod g+w "${EROOT}/var/lib/gentoo/news"
	fi
}
