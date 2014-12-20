# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

EBO_DESCRIPTION="Simple menu of EMBOSS applications"
EBO_EXTRA_ECONF="$(use_with ncurses curses)"

inherit emboss

KEYWORDS="~amd64 ~x86 ~x86-linux ~ppc-macos"
IUSE+=" ncurses"

RDEPEND+=" ncurses? ( sys-libs/ncurses )"
