# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

EBO_DESCRIPTION="wrappers for HMMER - Biological sequence analysis with profile HMMs"

inherit emboss

KEYWORDS="~amd64 ~x86 ~x86-linux ~ppc-macos"

RDEPEND+=" ~sci-biology/hmmer-${PV}"
